#if canImport(UIKit)
import SwiftUI

extension Image {
    public init(_ image: Camera.Image?) {
        if let uiImage: UIImage = UIImage(image: image) {
            self.init(uiImage: uiImage)
        } else {
            self.init("")
        }
    }
}

#Preview {
    Image(Camera.Image(data: data))
}

private extension UIImage {
    convenience init?(image: Camera.Image?) {
        guard let data: Data = image?.data else {
            return nil
        }
        self.init(data: data)
    }
}

private let data: Data = Data(base64Encoded: """
iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII=
""")!
#endif
