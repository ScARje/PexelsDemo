import SwiftUI

struct PhotoListView: View {

  @ObservedObject var viewModel = ViewModel()

  var body: some View {
    NavigationView {
      VStack {
        HStack(spacing: 16) {
          Text("PER PAGE:")
            .font(.plain)
          ForEach(viewModel.availablePhotosPerPage, id: \.description) { number in
            Text("\(number)")
              .font(number == viewModel.photosPerPage ? .large : .plain)
              .onTapGesture {
                if number != viewModel.photosPerPage {
                  viewModel.setPhotosPerPage(number)
                }
              }
          }
        }
        .frame(height: 60)
        if let error = viewModel.error {
          Text("ERROR / \((error as CustomStringConvertible).description)")
            .font(.plain)
        }
        if viewModel.isLoading {
          VStack {
            Spacer()
            ProgressView()
            Spacer()
          }
        } else if (viewModel.page?.photos ?? []).isEmpty {
          VStack {
            Spacer()
            Text("NOTHING HERE :(")
              .font(.plain)
            Spacer()
          }
        } else {
          ScrollView {
            VStack {
              ForEach(viewModel.page?.photos ?? [], id: \.id) { photo in
                NavigationLink(
                  destination: {
                    PhotoView(viewModel: {
                      PhotoView.ViewModel(photo: photo)
                    })
                  },
                  label: {
                    ZStack {
                      Rectangle()
                        .foregroundColor(.white)
                      VStack {
                        Image(uiImage: photo.preview)
                          .resizable()
                          .scaledToFill()
                          .frame(maxHeight: 200)
                          .clipped()
                        Text(photo.author.uppercased())
                          .font(.plain)
                          .padding(.vertical)
                      }
                    }
                    .cornerRadius(16)
                    .padding()
                    .shadow(radius: 16)
                    .contentShape(Rectangle())
                  }
                )
                .buttonStyle(.plain)
              }
            }
          }
          .refreshable {
            viewModel.refresh()
          }
        }
        if let page = viewModel.page?.page {
          HStack {
            Button {
              viewModel.prevPage()
            } label: {
              Text("PREV PAGE")
                .font(.plain)
            }
            .buttonStyle(.plain)
            .disabled(page == 1)
            .disabled(viewModel.isLoading)
            Spacer()
            if page > 1 {
              Text("\(page - 1)")
                .font(.plain)
                .onTapGesture {
                  viewModel.prevPage()
                }
            }
            Text("\(page)")
              .font(.large)
            Text("\(page + 1)")
              .font(.plain)
              .onTapGesture {
                viewModel.nextPage()
              }
            Spacer()
            Button {
              viewModel.nextPage()
            } label: {
              Text("NEXT PAGE")
                .font(.plain)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
          }
          .padding(.horizontal)
          .frame(height: 60)
        }
      }
    }
  }
}

extension Font {
  static let plain = Font.system(.body, design: .monospaced, weight: .bold)
  static let large = Font.system(.largeTitle, design: .monospaced, weight: .bold)
}

struct PhotoListView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoListView()
  }
}
