import UIKit

struct Photo {
  let id: Int
  let preview: UIImage
  let fullImageUrl: String
  let avgColor: String
  let author: String
  let alt: String
}

extension Photo {
  static let empty = Photo(
    id: 0,
    preview: .checkmark,
    fullImageUrl: "https://upload.wikimedia.org/wikipedia/en/a/a4/Hide_the_Pain_Harold_%28Andr%C3%A1s_Arat%C3%B3%29.jpg",
    avgColor: "#CF6F23",
    author: "Yegor Dobrodeyev",
    alt: "Hide the Pain Harold"
  )
}
