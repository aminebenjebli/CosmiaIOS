import SwiftUI

struct StoryView: View {
    var images: [String]
    @StateObject private var countTimer: CountTimer
    @Environment(\.presentationMode) var presentationMode // Environment variable for dismissing the view

    init(images: [String]) {
        self.images = images
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
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
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
}
