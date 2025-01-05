import SwiftUI

struct SettingsView: View {
    @State var showChangePassword: Bool = false
    @State var navigateToLogin: Bool = false
    @State private var navigateToAlbumView = false // Navigation state for AlbumView
    @State private var navigateToMyImagesView = false
    @State private var navigateToFeedbackSupport = false
    @State private var navigateToTermsConditions = false
    @State private var navigateToPrivacyPolicy = false
    @State private var navigateToAboutUs = false
    @State private var navigateToContactUs = false
    @StateObject var albumViewModel = AlbumViewModel()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.appAstro]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            ZodiacAnimation2()
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    // Add to Album Button
                    SettingButton(title: "Add Your Album", buttonColor: .appAstro, showArrow: true) {
                        navigateToAlbumView = true
                    }
                    .background(
                        NavigationLink(destination: AlbumView(), isActive: $navigateToAlbumView) {
                            EmptyView()
                        }
                        .hidden()
                    )

                    // My Album Button - Navigate to MyImagesView
                    SettingButton(title: "My Album", buttonColor: .appAstro, showArrow: true) {
                        navigateToMyImagesView = true
                    }
                    .background(
                        NavigationLink(destination: MyImagesView(), isActive: $navigateToMyImagesView) {
                            EmptyView()
                        }
                        .hidden()
                    )

                    Spacer()

                    // Change Password and Logout Buttons
                    VStack(spacing: 10) {
                                          NavigationLink(destination: EditPasswordView(), isActive: $showChangePassword) {
                                              EmptyView()
                                          }
                                          SettingButton(title: "Change Password", buttonColor: .appAstro, showArrow: true) {
                                              showChangePassword = true
                                          }
                                          SettingButton(title: "Feedback & Support", buttonColor: .appAstro, showArrow: true) {
                                              navigateToFeedbackSupport = true
                                          }
                                          .background(
                                              NavigationLink(destination: FeedbackSupportView(), isActive: $navigateToFeedbackSupport) {
                                                  EmptyView()
                                              }
                                              .hidden()
                                          )
                                          SettingButton(title: "Terms & Conditions", buttonColor: .appAstro, showArrow: true) {
                                              navigateToTermsConditions = true
                                          }
                                          .background(
                                              NavigationLink(destination: TermsConditionsView(), isActive: $navigateToTermsConditions) {
                                                  EmptyView()
                                              }
                                              .hidden()
                                          )
                                          SettingButton(title: "Privacy", buttonColor: .appAstro, showArrow: true) {
                                              navigateToPrivacyPolicy = true
                                          }
                                          .background(
                                              NavigationLink(destination: PrivacyPolicyView(), isActive: $navigateToPrivacyPolicy) {
                                                  EmptyView()
                                              }
                                              .hidden()
                                          )
                                          SettingButton(title: "About Us", buttonColor: .appAstro, showArrow: true) {
                                              navigateToAboutUs = true
                                          }
                                          .background(
                                              NavigationLink(destination: AboutUsView(), isActive: $navigateToAboutUs) {
                                                  EmptyView()
                                              }
                                              .hidden()
                                          )
                                          SettingButton(title: "Contact Us", buttonColor: .appAstro, showArrow: true) {
                                              navigateToContactUs = true
                                          }
                                          .background(
                                              NavigationLink(destination: ContactUsView(), isActive: $navigateToContactUs) {
                                                  EmptyView()
                                              }
                                              .hidden()
                                          )

                                          SettingButton(title: "Logout", buttonColor: .red, showArrow: false) {
                                              handleLogout()
                                          }
                                      }

                    Spacer()
                        .frame(height: 20)

                    // Social Media Links
                    HStack(spacing: 16) {
                        Image(systemName: "link.circle.fill")
                        Image(systemName: "network")
                        Image(systemName: "message.circle")
                        Image(systemName: "paperplane.circle")
                        Image(systemName: "phone.circle.fill")
                    }
                    .font(.title2)
                    .foregroundColor(.appAstro)

                    Text("Cosmia version Beta v1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom)
                }
                .padding()
            }
        }
        .cornerRadius(20)
        .background(
            NavigationLink(destination: Login(showSignup: .constant(false)), isActive: $navigateToLogin) {
                EmptyView()
            }
        )
    }
    
    private func handleLogout() {
        SessionManager.shared.clearAllSessions()
        UserSession.shared.clearSession()
        print("UserSession cleared.")
        navigateToLogin = true
    }
}

#Preview {
    SettingsView()
}
