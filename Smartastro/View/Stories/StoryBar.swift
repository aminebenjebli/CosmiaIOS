import SwiftUI
import PhotosUI

struct StoryBar: View {
    @StateObject private var storyViewModel = StoryViewModel()
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedStories: [Story] = []

    var body: some View {
        VStack {
            if storyViewModel.isLoading {
                ProgressView("Loading stories...")
            } else if let errorMessage = storyViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // Add Story Button
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            StoryCirclePlaceholder()
                        }
                        .onChange(of: selectedPhoto) { newItem in
                            loadSelectedPhoto(item: newItem)
                        }

                        // Display grouped stories (one circle per user)
                        ForEach(Array(storyViewModel.groupedStories.keys), id: \.self) { userId in
                            if let stories = storyViewModel.groupedStories[userId], let username = stories.first?.username {
                                StoryCircle(username: username, stories: stories)
                                    .onTapGesture {
                                        selectedStories = stories
                                    }
                            }
                        }


                    }
                    .padding()
                }
                .frame(height: 120)
            }
        }
        .onAppear { storyViewModel.fetchStories() }
        .fullScreenCover(isPresented: Binding(
            get: { !selectedStories.isEmpty },
            set: { _ in selectedStories = [] }
        )) {
            StoryView(images: selectedStories.map { $0.imageUrl })
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

struct StoryCirclePlaceholder: View {
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 80, height: 80)
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.indigo)
            }
            Text("Your Story")
                .font(.caption)
        }
    }
}

