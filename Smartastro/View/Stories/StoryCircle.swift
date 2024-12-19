import SwiftUI

struct StoryCircle: View {
    let username: String
    let stories: [Story]

    var body: some View {
        VStack {
            Circle()
                .strokeBorder(Color.orange, lineWidth: 3)
                .frame(width: 80, height: 80)
                .background(
                    AsyncImage(url: URL(string: stories.first?.imageUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .clipShape(Circle())
                )
            Text(username) // Display username
                .font(.caption)
                .lineLimit(1)
        }
    }
}

