import SwiftUI

struct TermsConditionsView: View {
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
                // Content ScrollView
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Section
                        Text("Terms & Conditions")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 20)

                        Text("Last updated: January 2025")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black.opacity(0.8))

                        Text("Please read our terms and conditions carefully before using our app.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(5)

                        Divider()
                            .background(Color.white.opacity(0.5))

                        // Terms Content
                        VStack(alignment: .leading, spacing: 15) {
                            Group {
                                Text("1. User Responsibility:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("2. Content Ownership:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("By uploading photos, videos, or other content, you affirm that you own the rights or have appropriate permissions to share such content.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("3. Prohibited Activities:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("You agree not to engage in activities such as harassment, spamming, or sharing explicit or inappropriate content.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)
                            }

                            Group {
                                Text("4. Privacy Policy:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("We value your privacy. Please review our Privacy Policy to understand how we collect, use, and share your information.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("5. Liability Disclaimer:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("Cosmia is not responsible for any loss or damage resulting from the use of our app, including user interactions and shared content.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("6. Modification of Terms:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("We reserve the right to modify these terms at any time. Continued use of the app signifies your agreement to the updated terms.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)
                            }

                            Group {
                                Text("7. Reporting Abuse:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("If you encounter any abusive or inappropriate behavior, please report it through our in-app reporting feature or contact support.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)

                                Text("8. Account Termination:")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.indigo)
                                Text("We reserve the right to suspend or terminate accounts that violate our terms and policies.")
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
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 10)
                }
                .padding(.horizontal)
                .background(Color.black.opacity(0.2))
            }
        }
    }
}

#Preview {
    TermsConditionsView()
}
