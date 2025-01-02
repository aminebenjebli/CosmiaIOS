import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @ObservedObject var viewModel: AlbumViewModel
    @Binding var isPresented: Bool

    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Photos")
                .font(.headline)
                .foregroundColor(.indigo)

            PhotosPicker(
                selection: $selectedItems,
                matching: .images,
                photoLibrary: .shared()
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.indigo, Color.blue]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(height: 150)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)

                        Text("Tap to select photos")
                            .font(.body)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                }
                .padding(.horizontal, 20)
            }
            .onChange(of: selectedItems) { newItems in
                Task {
                    // Retrieve selected assets
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                if !viewModel.selectedImages.contains(uiImage) {
                                    viewModel.addImage(uiImage)
                                } else {
                                    viewModel.removeImage(image: uiImage)
                                }
                            }
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 10)
            }

            Button(action: {
                isPresented = false
            }) {
                Text("Done")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
    }
}
