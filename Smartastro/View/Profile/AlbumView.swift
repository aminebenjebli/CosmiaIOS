import SwiftUI

struct AlbumView: View {
    @StateObject private var viewModel = AlbumViewModel()
    @State private var showImagePicker = false
    @State private var showAddImageSheet = false

    var body: some View {
        VStack {
            Button("Add Image") {
                showAddImageSheet.toggle()
            }
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)

            // Display selected images
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                        ZStack {
                            Image(uiImage: viewModel.selectedImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)

                            // X Button to Remove the Image
                            Button(action: {
                                viewModel.removeImage(at: index)
                            }) {
                                Image(systemName: "x.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.red)
                                    .padding(5)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .offset(x: 35, y: -35)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Button("Save to Album") {
                viewModel.saveAlbum()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top)
        }
        .sheet(isPresented: $showAddImageSheet) {
            ImagePickerView(viewModel: viewModel, isPresented: $showAddImageSheet)
        }
        .padding()
    }
}

#Preview {
    AlbumView()
}
