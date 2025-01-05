import SwiftUI

struct ContactUsView: View {
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .center, spacing: 30) {
                // Title
                Text("Contact Us")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 30)

                // Description
                Text("We are here to help! Feel free to reach out to us using the contact information below.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Contact Info Section
                VStack(alignment: .leading, spacing: 20) {
                    ContactInfoRow(icon: "envelope.fill", text: "support@cosmia.com", iconColor: .blue)
                    ContactInfoRow(icon: "phone.fill", text: "+216 54 327 348", iconColor: .green)
                    ContactInfoRow(icon: "globe", text: "www.cosmia.com", iconColor: .orange)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.2))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)

                Spacer()

                // Footer
                Text("Cosmia © 2025. All rights reserved.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.2))
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    )
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }
}

struct ContactInfoRow: View {
    let icon: String
    let text: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 15) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.2))
                )

            // Text
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    ContactUsView()
}
