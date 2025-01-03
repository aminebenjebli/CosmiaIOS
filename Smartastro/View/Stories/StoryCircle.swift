import SwiftUI

struct StoryCircle: View {
    let username: String
    let stories: [Story]

    var body: some View {
        VStack {
            Circle()
                .strokeBorder(stories.isEmpty ? Color.blue : Color.orange, lineWidth: 3)
                .frame(width: 80, height: 80)
                .background(
                    AsyncImage(url: URL(string: stories.first?.imageUrl ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        if stories.isEmpty {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                    .clipShape(Circle())
                )
            Text(username)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
