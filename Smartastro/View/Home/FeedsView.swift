import SwiftUI

struct FeedsView: View {
    @StateObject private var viewModel = FeedsViewModel()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.9), Color.pink.opacity(0.7)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 40) {
                    Text("✨ Your Daily Horoscope ✨")
                        .font(.system(size: 33, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.purple.opacity(0.6), radius: 10, x: 0, y: 4)
                        .multilineTextAlignment(.center)
                        .padding(.top, 50)

                    if let zodiacFeed = viewModel.dailyFeed {
                        VStack(spacing: 20) {
                            if let imageUrl = viewModel.dailyImageURL {
                                AsyncImage(url: imageUrl) { phase in
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
                                                    .stroke(LinearGradient(
                                                        gradient: Gradient(colors: [.white.opacity(0.8), .purple.opacity(0.8)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ), lineWidth: 3)
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
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                            }

                            VStack(spacing: 15) {
                                Text("Prediction for \(zodiacFeed.zodiacSign)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)

                                Text(zodiacFeed.message)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.85))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)

                                HStack(spacing: 20) {
                                    VStack(spacing: 10) {
                                        Text("Lucky Number")
                                            .font(.caption)
                                            .fontWeight(.light)
                                            .foregroundColor(.white.opacity(0.8))

                                        Text(zodiacFeed.luckyNumber)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.yellow)
                                    }

                                    VStack(spacing: 10) {
                                        Text("Lucky Color")
                                            .font(.caption)
                                            .fontWeight(.light)
                                            .foregroundColor(.white.opacity(0.8))

                                        Text(zodiacFeed.luckyColor)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.pink)
                                    }
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
                    } else {
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
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            viewModel.fetchDailyFeed()
        }
    }
}

#Preview {
    FeedsView()
}
