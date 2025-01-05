import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Section
                        Text("Privacy Policy")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 20)

                        Text("Effective Date: January 2025")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black.opacity(0.8))

                        Text("Your privacy is important to us. This policy explains how we collect, use, and protect your data.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(5)

                        Divider()
                            .background(Color.white.opacity(0.5))

                        // Privacy Policy Sections
                        VStack(alignment: .leading, spacing: 15) {
                            Group {
                                Text("1. Data Collection")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("We collect personal information such as your name, email address, and birth date to provide personalized features and enhance your app experience.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("2. Usage Data")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("Our app automatically collects data such as app usage patterns, device information, and IP addresses to optimize performance.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("3. Data Sharing")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("Your data will not be shared with third parties unless required by law or with your explicit consent.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)
                            }

                            Group {
                                Text("4. Data Protection")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("We use advanced security measures to protect your personal data from unauthorized access, alteration, or disclosure.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("5. Cookies")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("Our app uses cookies to enhance your user experience by remembering your preferences and login details.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("6. Your Rights")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("You have the right to access, update, or delete your personal data at any time. Contact us to exercise these rights.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)
                            }

                            Group {
                                Text("7. Data Retention")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("We retain your data only as long as necessary to provide you with the best experience and comply with legal obligations.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("8. Third-Party Services")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("We may use third-party services (e.g., analytics or payment processors) to improve our app. These services are bound by confidentiality agreements.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("9. Policy Updates")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("We reserve the right to update this policy. Any changes will be communicated via the app.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Footer
                VStack {
                    Divider()
                        .background(Color.white.opacity(0.5))

                    Text("For more information, contact us at privacy@cosmia.com")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 10)

                    Text("Cosmia © 2025. All rights reserved.")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.bottom, 10)
                }
                .padding(.horizontal)
                .background(Color.black.opacity(0.2))
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
