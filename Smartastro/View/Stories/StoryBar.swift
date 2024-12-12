import SwiftUI

struct StoryBar: View {
    let stories: [Story] = [
        Story(name: "Votre story", image: "taurus"),
        Story(name: "Aziz kaboudi", image: "pisces"),
        Story(name: "houssemzalila", image: "virgo"),
        Story(name: "Baha haj mabrouk", image: "scorpio"),
        Story(name: "Med Ali", image: "aries")
    ]
    
    @State private var isPresentingStory = false // Track if StoryView is active
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(stories) { story in
                    VStack {
                        ZStack {
                            // Circle with gradient for border
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: story.isCurrentUser ? [.blue, .blue] : [.pink, .orange]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 80, height: 80)
                            
                            // Profile Image
                            Image(story.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                            
                            // Add "+" icon for current user
                            if story.isCurrentUser {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 25, height: 25)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 20, y: 20)
                            }
                        }
                        
                        // Story name
                        Text(story.name)
                            .font(.caption)
                            .lineLimit(1)
                            .frame(width: 80) // Limit text width
                            .multilineTextAlignment(.center)
                    }
                    .onTapGesture {
                        isPresentingStory = true
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 120) // Adjust height of the scrollable bar
        // Present StoryView when any story is tapped
        .fullScreenCover(isPresented: $isPresentingStory) {
            StoryView() // Show the static StoryView
        }
    }
}

struct Story: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let isCurrentUser: Bool = false
}

#Preview {
    StoryBar()
}
