import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @ObservedObject var viewModel: AlbumViewModel
    @Binding var isPresented: Bool

    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItems,
                matching: .images,
                photoLibrary: .shared()) {
                    Text("Select Photos")
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

            Button("Done") {
                isPresented = false
            }
            .padding()
        }
        .padding()
    }
}
