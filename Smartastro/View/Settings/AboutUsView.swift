import SwiftUI

struct AboutUsView: View {
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    // Title Section
                    Text("About Us")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 30)
                    
                    // Zodiac Signs Animation
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.5), Color.blue.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        ZodiacAnimationAboutUs()
                            .frame(width: 80, height: 80)
                    }
                    
                    // Welcome Message
                    Text("Welcome to Cosmia!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Our Mission")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.indigo)
                        
                        Text("At Cosmia, we strive to connect people and make life simpler through innovative technology. Our mission is to create meaningful connections and offer personalized astrological insights to enrich your life.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(5)
                            .multilineTextAlignment(.center)
                        
                        Text("Our Vision")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.indigo)
                        
                        Text("We aim to be the leading platform in combining technology and astrology, providing users with a seamless and empowering experience.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(5)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Contact Information
                    // Contact Information Section
                    VStack(spacing: 15) {
                        Text("Contact Us")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.indigo)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill")
                                    .font(.title2)
                                    .foregroundColor(.indigo)
                                Text("Email: support@cosmia.com")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            HStack(spacing: 10) {
                                Image(systemName: "phone.fill")
                                    .font(.title2)
                                    .foregroundColor(.indigo)
                                Text("Phone: +216 54 327 348-COSMIA")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            HStack(spacing: 10) {
                                Image(systemName: "link")
                                    .font(.title2)
                                    .foregroundColor(.indigo)
                                Text("Website: www.cosmia.com")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.3))
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                        )
                    }
                    
                    // Footer
                    Text("Cosmia © 2025. All rights reserved.")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.2))
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        )
                        .padding(.top, 20)
                    
                }
            }
        }
    }
    
    // ZodiacAnimation View
    struct ZodiacAnimationAboutUs: View {
        @State private var rotationAngle: Double = 0
        
        let zodiacSigns = [
            "♈︎", "♉︎", "♊︎", "♋︎", "♌︎", "♍︎",
            "♎︎", "♏︎", "♐︎", "♑︎", "♒︎", "♓︎"
        ]
        
        var body: some View {
            ZStack {
                ForEach(0..<zodiacSigns.count, id: \.self) { index in
                    Text(zodiacSigns[index])
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                        .offset(y: -30) // Position around the circle
                        .rotationEffect(.degrees(Double(index) * 30), anchor: .center) // Distribute around circle
                }
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
        }
    }
}
#Preview {
    AboutUsView()
}
