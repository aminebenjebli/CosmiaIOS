import SwiftUI
import PhotosUI

struct StoryBar: View {
    @StateObject private var storyViewModel = StoryViewModel()
    @State private var showImagePicker = false
    @State private var selectedPhoto: UIImage? = nil
    @State private var selectedStories: [Story] = []
    @State private var selectedUsername: String? = nil // To hold the username of selected stories

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
                        // Current User's Story Circle
                        StoryCircle(
                            username: "Your Story",
                            stories: storyViewModel.userStories
                        )
                        .onTapGesture {
                            print("Current user stories: \(storyViewModel.userStories)")
                            if !storyViewModel.userStories.isEmpty {
                                selectedStories = storyViewModel.userStories
                                selectedUsername = nil // No username for the current user
                            }
                        }
                        .overlay(
                            AddStoryButton {
                                showImagePicker.toggle()
                            }
                            .offset(x: 30, y: -30) // Position in the top-right corner
                        )
                        .sheet(isPresented: $showImagePicker) {
                            ImagePickerViewForStories(viewModel: storyViewModel, isPresented: $showImagePicker)
                        }

                        // Other Users' Stories
                        ForEach(Array(storyViewModel.groupedStories.keys), id: \.self) { userId in
                            if let stories = storyViewModel.groupedStories[userId], let username = stories.first?.username {
                                StoryCircle(username: username, stories: stories)
                                    .onTapGesture {
                                        selectedStories = stories
                                        selectedUsername = username // Set username for other users
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
            StoryView(images: selectedStories.map { $0.imageUrl }, username: selectedUsername)
        }
    }
}


struct AddStoryButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 30, height: 30)
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.white)
            }
        }
    }
}
