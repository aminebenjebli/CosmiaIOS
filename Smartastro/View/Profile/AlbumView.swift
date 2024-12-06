import SwiftUI

struct AlbumView: View {
    @StateObject private var viewModel = AlbumViewModel()
    @State private var showImagePicker = false
    @State private var showAddImageSheet = false
    @State private var showSuccesMessage = false

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Zodiac Animation
            ZodiacAnimationView()
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                                   Spacer() // Push the icon to the right edge
                                   Button(action: {
                                       viewModel.saveAlbum()
                                       DispatchQueue.main.async {
                                           showSuccesMessage = true
                                       }
                                       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                           showSuccesMessage = false
                                       }
                                   }) {
                                       Image(systemName: "tray.and.arrow.down.fill")
                                           .resizable()
                                           .frame(width: 30, height: 30)
                                           .foregroundColor(.purple)
                                           .padding()
                                   }
                               }
                               .padding(.top, -30) // Adjust spacing at the top
                // Display selected images
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                // Image display
                                Image(uiImage: viewModel.selectedImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                    .allowsHitTesting(false) // Prevent the image from intercepting taps

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
                                }
                                .offset(x: 10, y: -10) // Adjust offset for better placement
                            }
                        }

                    }
                    .padding()
                }

                // Add Image Button at the bottom
                Button("Add Image") {
                    showAddImageSheet.toggle()
                }
                .padding()
                .frame(maxWidth: .infinity) // Make the button take the maximum available width
                .frame(height: 50) // Adjust height if needed
                .background(Color.purple.opacity(0.8)) // Add opacity to the background color
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20) // Add spacing at the top

                // Show success message
                if showSuccesMessage {
                    Text("Album saved successfully!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .transition(.opacity)
                        .animation(.easeIn, value: showSuccesMessage)
                }
            }
            .sheet(isPresented: $showAddImageSheet) {
                ImagePickerView(viewModel: viewModel, isPresented: $showAddImageSheet)
            }
            .padding()
        }
    }
}

#Preview {
    AlbumView()
}
