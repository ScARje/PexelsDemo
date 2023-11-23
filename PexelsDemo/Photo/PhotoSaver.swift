import Foundation
import UIKit

final class PhotoSaver: NSObject {
  var errorHandler: ((Error) -> Void)?

  func writeToPhotoAlbum(image: UIImage?) {
    guard let image else { return }
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
  }

  @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      errorHandler?(error)
    }
  }
}
