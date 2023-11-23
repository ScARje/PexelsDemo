struct PhotoPageDto: Decodable {
  let page: Int
  let perPage: Int
  let photos: [PhotoDto]
  let nextPage: String

  private enum CodingKeys: String, CodingKey {
    case page
    case perPage = "per_page"
    case photos
    case nextPage = "next_page"
  }
}
