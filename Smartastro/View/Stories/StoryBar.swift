import SwiftUI
import PhotosUI

struct StoryBar: View {
    @StateObject private var storyViewModel = StoryViewModel()
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedStory: Story?

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Add Story Button
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                            }
                            Text("Your Story")
                                .font(.caption)
                        }
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        loadSelectedPhoto(item: newItem)
                    }

                    // Show Stories
                    ForEach(storyViewModel.stories) { story in
                        VStack {
                            Circle()
                                .strokeBorder(story.isCurrentUser ? Color.blue : Color.orange, lineWidth: 3)
                                .frame(width: 80, height: 80)
                                .background(
                                    AsyncImage(url: URL(string: story.images.first ?? "")) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .clipShape(Circle())
                                )
                            Text(story.name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .onTapGesture {
                            selectedStory = story
                        }
                    }
                }
                .padding()
            }
            .frame(height: 120)
        }
        .onAppear { storyViewModel.fetchStories() }
        .fullScreenCover(item: $selectedStory) { story in
            StoryView(images: story.images)
        }
    }

    private func loadSelectedPhoto(item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                storyViewModel.uploadStory(image: uiImage)
            }
        }
    }
}
