import SwiftUI

struct FeedsView: View {
    @StateObject private var viewModel = FeedsViewModel()
    @State private var showHistory = false
    @State private var selectedFeed: FeedModel?

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.9), Color.pink.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 40) {
                        Text("✨ Your Daily Horoscope ✨")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.purple.opacity(0.6), radius: 10, x: 0, y: 4)
                            .multilineTextAlignment(.center)
                            .padding(.top, 50)

                        Text("Time left until next horoscope: \(viewModel.countdownText)")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))

                        if let zodiacFeed = viewModel.dailyFeed {
                            ZodiacFeedView(feed: zodiacFeed, imageURL: viewModel.dailyImageURL)
                        } else {
                            HoroscopeLoadingView()
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                viewModel.fetchDailyFeed()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.fetchFeedHistory(email: SessionManager.shared.getActiveSession()?.email ?? "")
                        showHistory = true
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showHistory) {
                HistoryView(history: viewModel.feedHistory, onSelect: { feed in
                    selectedFeed = feed
                    showHistory = false
                })
            }
            .sheet(item: $selectedFeed) { feed in
                FeedDetailsView(feed: feed, onBack: {
                    selectedFeed = nil
                    showHistory = true // Reopen the history view
                })
            }
        }
    }
}

struct HoroscopeLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
            Text("Fetching your horoscope...")
                .foregroundColor(.white.opacity(0.8))
                .font(.caption)
                .padding(.top, 8)
        }
    }
}

struct ZodiacFeedView: View {
    let feed: FeedModel
    let imageURL: URL?

    var body: some View {
        VStack(spacing: 20) {
            if let imageURL = imageURL {
                FeedImageView(imageURL: imageURL)
            }

            VStack(spacing: 15) {
                Text("Prediction for \(feed.zodiacSign)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)

                Text(feed.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                HStack(spacing: 20) {
                    LuckyNumberView(luckyNumber: feed.luckyNumber)
                    LuckyColorView(luckyColor: feed.luckyColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.25))
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.horizontal, 20)
    }
}

struct FeedImageView: View {
    let imageURL: URL

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280, maxHeight: 280)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white.opacity(0.8), .purple.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 6)
            case .failure:
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280, maxHeight: 280)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct LuckyNumberView: View {
    let luckyNumber: Int

    var body: some View {
        VStack(spacing: 10) {
            Text("Lucky Number")
                .font(.caption)
                .fontWeight(.light)
                .foregroundColor(.white.opacity(0.8))

            Text("\(luckyNumber)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
        }
    }
}

struct LuckyColorView: View {
    let luckyColor: String

    var body: some View {
        VStack(spacing: 10) {
            Text("Lucky Color")
                .font(.caption)
                .fontWeight(.light)
                .foregroundColor(.white.opacity(0.8))

            Text(luckyColor)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.pink)
        }
    }
}

struct HistoryView: View {
    let history: [FeedModel]
    let onSelect: (FeedModel) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.9), Color.pink.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(history) { feed in
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.black.opacity(0.3))
                                    .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 5)
                                
                                HStack {
                                    AsyncImage(url: URL(string: feed.image)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.white.opacity(0.8), lineWidth: 2)
                                            )
                                    } placeholder: {
                                        ProgressView()
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(feed.zodiacSign)
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        Text(feed.createdAt, style: .date)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    Spacer()
                                    Button(action: { onSelect(feed) }) {
                                        Text("Details")
                                            .font(.system(size: 14, weight: .bold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(10)
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitle("History", displayMode: .inline)
        }
    }
}

struct FeedDetailsView: View {
    let feed: FeedModel
    let onBack: () -> Void // Closure to handle back navigation

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.9), Color.pink.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 30) {
                    AsyncImage(url: URL(string: feed.image)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.8), Color.pink.opacity(0.7)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 6)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                    .frame(maxWidth: 300, maxHeight: 300)
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 20) {
                        Text("Horoscope Details")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.purple.opacity(0.6), radius: 4, x: 0, y: 2)

                        Text(feed.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)

                        HStack {
                            DetailBadge(title: "Lucky Number", value: "\(feed.luckyNumber)", color: .yellow)
                            DetailBadge(title: "Lucky Color", value: feed.luckyColor, color: .pink)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                            .shadow(color: Color.black.opacity(0.6), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .overlay(
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 50),
                alignment: .topLeading
            )
        }
        .navigationTitle(formattedDate(feed.createdAt))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}
#Preview {
    FeedsView()
}
