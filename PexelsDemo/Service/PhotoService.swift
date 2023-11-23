import Foundation
import UIKit

final class PhotoService {

  private var cachedPhotos: [String: UIImage] = [:]

  enum DataError: Error, CustomStringConvertible {
    case urlError
    case imageError

    var description: String {
      switch self {
      case .urlError:
        return "INVALID URL"
      case .imageError:
        return "INVALID IMAGE"
      }
    }
  }

  func page(number: Int, photosPerPage: Int) async throws -> PhotoPage {
    /// For multiple API queries it's better to create separate enum with different endpoints
    /// For this case constructing URL on the spot should be enough
    guard let url = URL(string: "\(pexelsApiUrl)curated/?page=\(number)&per_page=\(photosPerPage)") else {
      throw DataError.urlError
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.setValue(pexelsApiKey, forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: urlRequest)

    let dto = try JSONDecoder().decode(PhotoPageDto.self, from: data)

    let photos = try await withThrowingTaskGroup(of: Photo.self) { [weak self] group in
      guard let self else { return [Photo]() }
      for photoDto in dto.photos {
        group.addTask {
          var image: UIImage
          if let cachedImage = self.cachedPhotos[photoDto.src.medium] {
            image = cachedImage
          } else {
            image = try await self.loadImage(stringUrl: photoDto.src.medium)
          }
          return Photo(
            id: photoDto.id,
            preview: image,
            fullImageUrl: photoDto.src.original,
            avgColor: photoDto.avgColor,
            author: photoDto.photographer,
            alt: photoDto.alt
          )
        }
      }

      return try await group.reduce(into: [Photo]()) { photoArray, result in
        photoArray.append(result)
      }
    }

    let page = PhotoPage(
      page: dto.page,
      perPage: dto.perPage,
      photos: photos,
      nextPage: dto.nextPage
    )

    for photoDto in dto.photos {
      if let photo = page.photos.first(where: { $0.id == photoDto.id }) {
        cachedPhotos[photoDto.src.medium] = photo.preview
      }
    }

    return page
  }

  func loadImage(stringUrl: String) async throws -> UIImage {
    guard let url = URL(string: stringUrl) else {
      throw DataError.urlError
    }

    let (data, _) = try await URLSession.shared.data(from: url)

    guard let image = UIImage(data: data) else {
      throw DataError.imageError
    }

    return image
  }

  /// Better to store in some kind of config file
  private let pexelsApiUrl = "https://api.pexels.com/v1/"
  private let pexelsApiKey = "d0m3wwVdR57W8ShrHSuGtrSc8pVM0pRJ63hAyv2gy6VfW56C4wS8wvp7"
}
