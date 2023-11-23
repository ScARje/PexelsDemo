import SwiftUI

extension PhotoListView {
  final class ViewModel: ObservableObject {
    @Published private(set) var page: PhotoPage?
    @Published private(set) var photosPerPage = 15
    @Published private(set) var availablePhotosPerPage = [15, 30, 45, 60]
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let service = PhotoService()

    init() {
      Task {
        await loadPage(number: 1)
      }
    }

    @MainActor
    func loadPage(number: Int, hideLoading: Bool = false) {
      guard !isLoading else {
        return
      }

      Task {
        if !hideLoading {
          isLoading = true
        }
        do {
          page = try await service.page(number: number, photosPerPage: photosPerPage)
          isLoading = false
        } catch {
          self.error = error
          isLoading = false
        }
      }
    }

    @MainActor
    func nextPage() {
      guard let page else { return }

      loadPage(number: page.page + 1)
    }

    @MainActor
    func prevPage() {
      guard let page else { return }

      loadPage(number: page.page - 1)
    }

    @MainActor
    func refresh(hideLoading: Bool = true) {
      guard let page else { return }

      loadPage(number: page.page, hideLoading: hideLoading)
    }

    @MainActor
    func setPhotosPerPage(_ photosPerPage: Int) {
      self.photosPerPage = photosPerPage

      refresh(hideLoading: false)
    }
  }
}
