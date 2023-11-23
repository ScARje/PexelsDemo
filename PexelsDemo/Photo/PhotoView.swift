import SwiftUI

struct PhotoView: View {

  @ObservedObject private var viewModel: ViewModel

  init(viewModel: (() -> ViewModel)) {
    self.viewModel = viewModel()
  }

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 32) {
        if let error = viewModel.error {
          Text("ERROR / \((error as CustomStringConvertible).description)")
            .font(.plain)
        }
        if let image = viewModel.image {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .cornerRadius(16)
            .contextMenu {
              Button {
                viewModel.saveToPhotos()
              } label: {
                Label("Save to Photos", systemImage: "square.and.arrow.down")
              }
            }
        } else if viewModel.isLoading {
          ProgressView()
            .frame(height: 300)
        }
        HStack {
          Text("AUTHOR /")
            .font(.plain)
          Text(viewModel.author.uppercased())
            .font(.plain)
        }
        if !viewModel.alt.isEmpty {
          HStack {
            Text("DESCRIPTION /")
              .font(.plain)
            Text(viewModel.alt.uppercased())
              .font(.plain)
          }
        }
        if let color = viewModel.color {
          HStack {
            Text("AVERAGE COLOR /")
              .font(.plain)
            Circle()
              .frame(width: 32, height: 32)
              .foregroundColor(color)
          }
        }
        Spacer()
      }
    }
    .padding()
    .onAppear {
      viewModel.load()
    }
  }
}

struct PhotoView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoView(viewModel: { .init(photo: .empty) })
  }
}
