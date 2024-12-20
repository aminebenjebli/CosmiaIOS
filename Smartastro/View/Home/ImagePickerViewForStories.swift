import SwiftUI
import PhotosUI

struct ImagePickerViewForStories: View {
    @ObservedObject var viewModel: StoryViewModel
    @Binding var isPresented: Bool

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false // Toggle for the camera view
    
    var body: some View {
        ZStack {
            // Background
            Color.white.edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                // Cancel Button (X) at the top-right
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30) // Smaller size for cancel button
                            .foregroundColor(.red)
                    }
                    .padding()
                }

                Spacer()

                // Centered Select from Gallery Button (Larger)
                PhotosPicker(
                    selection: $selectedItems,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120) // Larger size
                            .foregroundColor(.blue)
                        Text("Select from Gallery")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .onChange(of: selectedItems) { newItems in
                    Task {
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                viewModel.uploadStory(image: uiImage)
                            }
                        }
                        isPresented = false // Dismiss after uploading
                    }
                }

                Spacer()

                // Take a Photo Button (Smaller size) at the bottom-left
                HStack {
                    Button(action: {
                        showCamera.toggle()
                    }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60) // Smaller size for the camera icon
                                .foregroundColor(.purple)
                            Text("Take a Photo")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    .sheet(isPresented: $showCamera) {
                        CameraView(isPresented: $showCamera) { capturedImage in
                            if let image = capturedImage {
                                viewModel.uploadStory(image: image)
                            }
                        }
                    }
                    Spacer() // Push the button to the left
                }
                .padding(.bottom, 20)
                .padding(.leading, 20)
            }
        }
    }
}

// Camera View Implementation
struct CameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onCapture: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.onCapture(image)
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
