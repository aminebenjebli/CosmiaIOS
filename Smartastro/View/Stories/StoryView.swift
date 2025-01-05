import SwiftUI

struct StoryView: View {
    var images: [String]
    var username: String? // Added username parameter
    @StateObject private var countTimer: CountTimer
    @Environment(\.presentationMode) var presentationMode // Environment variable for dismissing the view
    @State private var comment: String = "" // State for the comment input

    init(images: [String], username: String?) {
        self.images = images
        self.username = username
        self._countTimer = StateObject(wrappedValue: CountTimer(items: images.count, interval: 4.0))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Display current story image
                if let imageURL = URL(string: images[safe: Int(countTimer.progress)] ?? "") {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                                            countTimer.advancePage(by: 1) // Go to the next story
                                                            if Int(countTimer.progress) >= images.count {
                                                                presentationMode.wrappedValue.dismiss() // Dismiss when all stories are done
                                                            }
                                                        }
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                }

                // Username Display (if available)
                if let username = username {
                    HStack {
                        Text(username)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading)
                        Spacer()
                    }
                    .padding(.top, 40)
                }

                // Loading Bars
                HStack(spacing: 4) {
                    ForEach(images.indices, id: \.self) { index in
                        LoadingBar(progress: min(max(CGFloat(countTimer.progress) - CGFloat(index), 0.0), 1.0))
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .background(Color.black.opacity(0.2))

                // Tap to Navigate
                HStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            countTimer.advancePage(by: -1)
                        }
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            countTimer.advancePage(by: 1)
                        }
                }

                // Footer for Commenting
                VStack {
                    Spacer()

                    HStack {
                        TextField("Add a comment...", text: $comment)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity)

                        Button(action: {
                            sendComment()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                }

                // Dismiss Button
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.top, 30) // Adjust as needed
                    .padding(.trailing, 20) // Adjust as needed
                }
            }
            .onAppear { countTimer.start() }
            .onDisappear { countTimer.stop() }
        }
    }

    private func sendComment() {
        // Logic to send a comment
        print("Comment sent: \(comment)")
        comment = "" // Clear the input after sending
    }
}
