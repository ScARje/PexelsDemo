import SwiftUI

extension PhotoView {
  final class ViewModel: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    var author: String {
      photo.author
    }

    var alt: String {
      photo.alt
    }

    var color: Color? {
      guard let uiColor = uiColor(from: photo.avgColor) else {
        return nil
      }
      return Color(uiColor: uiColor)
    }

    private let photo: Photo
    private let service = PhotoService()

    init(photo: Photo) {
      self.photo = photo
    }

    @MainActor
    func load() {
      Task {
        isLoading = true
        do {
          image = try await service.loadImage(stringUrl: photo.fullImageUrl)
          isLoading = false
        } catch {
          self.error = error
          isLoading = false
        }
      }
    }

    func saveToPhotos() {
      let photoSaver = PhotoSaver()
      photoSaver.errorHandler = { [weak self] error in
        self?.error = error
      }
      photoSaver.writeToPhotoAlbum(image: image)
    }

    private func uiColor(from hex: String) -> UIColor? {
      guard !hex.isEmpty else {
        return nil
      }

      var hex = hex
      hex.remove(at: hex.startIndex)

      var rgbValue: UInt64 = 0
      Scanner(string: hex).scanHexInt64(&rgbValue)

      return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
      )
    }
  }
}
