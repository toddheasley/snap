#if canImport(UIKit)
import UIKit
import AVFoundation

protocol CameraViewDelegate {
    func cameraToggledCapture(isCapturing: Bool)
    func cameraCapturedImage(_ image: Camera.Image)
    func cameraFailed(error: Error)
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var delegate: CameraViewDelegate?
    
    private(set) var isCapturing = false {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.cameraToggledCapture(isCapturing: self.isCapturing)
            }
            if isCapturing {
                
                // Flash view to indicate shutter action
                view.alpha = 0.0
                UIView.animate(withDuration: 0.35) {
                    self.view.alpha = 1.0
                }
            }
        }
    }
    
    func capture() {
        guard !isCapturing, let _ = deviceInput else {
            return
        }
        isCapturing = true
        photoOutput.connection(with: .video)?.videoRotationAngle = UIDevice.current.videoRotationAngle
        DispatchQueue.camera.async {
            self.photoOutput.capturePhoto(with: .camera, delegate: self)
        }
    }
    
    func autoFocus(at devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        focus(at: devicePoint)
    }
    
    func zoom(to factor: CGFloat = 1.0) {
        DispatchQueue.camera.async {
            guard let device = self.deviceInput?.device else { return }
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = min(max(factor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
                device.unlockForConfiguration()
            } catch { }
        }
    }
    
    required init(delegate: CameraViewDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc dynamic private var deviceInput: AVCaptureDeviceInput?
    private let videoPreview: VideoPreview = VideoPreview()
    private let session: AVCaptureSession = AVCaptureSession()
    private let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private var observations: [NSKeyValueObservation] = []
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        autoFocus(at: videoPreview.previewLayer.captureDevicePointConverted(fromLayerPoint: recognizer.location(in: recognizer.view)))
    }
    
    @objc private func subjectAreaDidChange(_ notification: NSNotification) {
        autoFocus()
    }
    
    @objc private func sessionRuntimeError(_ notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
            return
        }
        switch error.code {
        case .mediaServicesWereReset:
            DispatchQueue.camera.async {
                if self.session.isRunning {
                    self.session.startRunning()
                }
            }
            fallthrough
        default:
            self.view.setNeedsLayout()
        }
    }
    
    @objc private func sessionInterrupted(_ notification: NSNotification) {
        view.setNeedsLayout()
    }
    
    @objc private func sessionInterruptionEnded(_ notification: NSNotification) {
        view.setNeedsLayout()
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus, exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure, at devicePoint: CGPoint) {
        DispatchQueue.camera.async {
            do {
                guard let device = self.deviceInput?.device else { return }
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported,
                   device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                if device.isExposurePointOfInterestSupported,
                   device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                device.isSubjectAreaChangeMonitoringEnabled = false
                device.torchMode = .off
                device.unlockForConfiguration()
            } catch { }
        }
    }
    
    private func configureSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in
                self.configureSession()
            }
        case .authorized:
            guard let deviceInput: AVCaptureDeviceInput = .camera(Camera.device) else {
                DispatchQueue.main.async {
                    self.delegate?.cameraFailed(error: AVError(.deviceNotConnected))
                }
                break
            }
            DispatchQueue.camera.async {
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    self.deviceInput = deviceInput
                }
                if self.session.canAddOutput(self.photoOutput) {
                    self.photoOutput.maxPhotoQualityPrioritization = .quality
                    self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = false
                    self.photoOutput.enabledSemanticSegmentationMatteTypes = []
                    self.photoOutput.isLivePhotoCaptureEnabled = false
                    self.session.addOutput(self.photoOutput)
                }
                self.session.commitConfiguration()
                self.zoom()
            }
        default:
            DispatchQueue.main.async {
                self.delegate?.cameraFailed(error: AVError(.applicationIsNotAuthorizedToUseDevice))
            }
        }
    }
    
    private func startSession() {
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange(_:)), name: .AVCaptureDeviceSubjectAreaDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError(_:)), name: .AVCaptureSessionRuntimeError, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterrupted(_:)), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded(_:)), name: .AVCaptureSessionInterruptionEnded, object: session)
        
        DispatchQueue.camera.async {
            self.observations.append(self.session.observe(\.isRunning, options: .new) { _, change in
                DispatchQueue.main.async {
                    self.view.setNeedsLayout()
                }
            })
            
            self.session.startRunning()
        }
    }
    
    private func stopSession() {
        DispatchQueue.camera.async {
            self.session.stopRunning()
            
            for observation in self.observations {
                observation.invalidate()
            }
            self.observations = []
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UIViewController
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoFocus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
        
        setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSession()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        videoPreview.addGestureRecognizer(recognizer)
        
        videoPreview.previewLayer.session = session
        view = videoPreview
        
        configureSession()
    }
    
    /*
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    override var shouldAutorotate: Bool { false }
     */ // Ignored by `UIViewControllerRepresentable`
    
    // MARK: AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data: Data = photo.fileDataRepresentation() {
            DispatchQueue.main.async {
                self.delegate?.cameraCapturedImage(Camera.Image(AVCapturePhotoSettings.camera.fileType, data: data))
            }
        } else {
            DispatchQueue.main.async {
                self.delegate?.cameraFailed(error: error ?? AVError(.contentIsUnavailable))
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        isCapturing = false
        if let error {
            delegate?.cameraFailed(error: error)
        }
    }
}

private extension AVCaptureDeviceInput {
    static func camera(_ device: Camera.Device = .default()) -> Self? {
        for deviceType in device.deviceTypes {
            guard let _device: AVCaptureDevice = .default(deviceType, for: .video, position: device.position),
                  let deviceInput: Self = try? Self(device: _device) else {
                continue
            }
            return deviceInput
        }
        return nil
    }
}

private extension AVCapturePhotoSettings {
    static var camera: AVCapturePhotoSettings {
        return AVCapturePhotoSettings(photoQualityPrioritization: Camera.quality, flashMode: Camera.flash)
    }
    
    var fileType: UTType {
        return UTType(processedFileType?.rawValue ?? "") ?? .image
    }
    
    private convenience init(photoQualityPrioritization: AVCapturePhotoOutput.QualityPrioritization, flashMode: AVCaptureDevice.FlashMode = .auto) {
        self.init()
        self.photoQualityPrioritization = photoQualityPrioritization
        self.flashMode = flashMode
    }
}

private extension DispatchQueue {
    static let camera: DispatchQueue = DispatchQueue(label: "camera")
}
#endif
