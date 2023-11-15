# `Snap`

__Point-and-shoot camera for iOS apps__

![](docs/camera.jpg)

### Supported Platforms

Written in [Swift](https://developer.apple.com/swift) 5.9 for [iOS](https://developer.apple.com/ios) 17. Build with [Xcode](https://developer.apple.com/xcode) 15 or newer.

## Ready to Use

![](docs/camera.png)

Present `Snap.Camera` using one of two included view modifiers for sheet and full-screen-cover modal presentations:

```swift
import Snap

@State var isPresented: Bool = false
@State var isCapturing: Bool = false

Button(action: { isPresented.toggle() }) {
    Label("Camera", systemImage: "camera")
}
.sheet($isPresented) {
    Camera($isCapturing) { image in
        // image.fileType: public.jpeg
        // image.data: 2901515 bytes
    }
}
```

Toggle `$isCapturing` true to trigger the shutter programmatically. Captured still images are delivered as `Data` with `UTType public.jpeg`.

`Snap.Camera` automatically selects the 1x-iest built-in rear camera available. Easily flip that to front-facing camera or pick your own:

```swift
import Snap

Camera.device = .default() // .default(.back)
Camera.device = .default(.front)
Camera.device = Camera.Device([
    .builtInDualCamera,
    .builtInWideAngleCamera // Select first available
], position: .back)

Camera.quality = .balanced // Default
Camera.quality = .speed 
Camera.quality = .quality

Camera.flash = .off // Default
Camera.flash = .auto
```

## Kit of Parts

### `Camera`

`Camera` holds the core functionality:

* Interface binding to trigger the camera shutter
* Handler to deliver a JPEG image of the configured quality, using the configured camera
* Live video preview that scales to fill its SwiftUI containing view

Use `Camera.shutterToggle(_ alignment: Alignment)` modifier to add a shutter button:

```swift
@State var isCapturing: Bool = false
@State var error: Error? = nil

Camera($isCapturing, error: $error) { image in
    // image.fileType: public.jpeg
    // image.data: 2901515 bytes
}
.shutterToggle() // Default alignment: .bottom
```

### `DisableIdleTimer`

The `Snap.Camera` sheet/full-screen presentations use a handy `ViewModifier` to keep the screen awake:

```swift
import Snap

EmptyView()
    .disableIdleTimer() // .disableIdleTimer(300.0)
    .disableIdleTimer(86400.0) // Lowest value wins
```

### `ImagePicker`

SwiftUI is gonna get a first-party camera `Picker` of some kind _eventually_. In the meantime, `ImagePicker` wraps [`UIImagePickerController`](https://developer.apple.com/documentation/uikit/uiimagepickercontroller) for when you need features that `Snap.Camera` doesn't cover:

* User-adjustable zoom and flash
* Hardware volume button shutter release
* Movie recording

![](docs/image-picker.png)

Use the provided view modifier to configure and present `ImagePicker`, then handle any captured media:

```swift
import Snap

@State private var isPresented: Bool = false

Button(action: { isPresented.toggle() }) {
    Label("Camera", systemImage: "camera")
}
.imagePicker($isPresented, media: [.image, .movie]) { info in
    // info: [UIImagePickerController.InfoKey: Any]
}
```

⚠️ `UIImagePickerController` is designed to be used locked in portrait orientation only, but `UIViewControllerRepresentable` ignores view controller orientation locking. Hilarity ensues _unless_ your app is portrait only. Otherwise, stick to presenting from UIKit for now.
