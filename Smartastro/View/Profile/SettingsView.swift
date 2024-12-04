import SwiftUI

struct SettingsView: View {
    @State var showChangePassword: Bool = false
    @State var navigateToLogin: Bool = false

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


                    // Settings Options
                    VStack(spacing: 10) {
                        SettingButton(title: "Feedback & Support", buttonColor: .appAstro, showArrow: true) {
                            // Navigate to Feedback & Support Page
                        }
                        SettingButton(title: "Terms & Conditions", buttonColor: .appAstro, showArrow: true) {
                            // Navigate to Terms & Conditions Page
                        }
                        SettingButton(title: "Privacy", buttonColor: .appAstro, showArrow: true) {
                            // Navigate to Privacy Page
                        }
                        SettingButton(title: "About Us", buttonColor: .appAstro, showArrow: true) {
                            // Navigate to About Us Page
                        }
                        SettingButton(title: "Contact Us", buttonColor: .appAstro, showArrow: true) {
                            // Navigate to Contact Us Page
                        }
                    }

                    Spacer()

                    // Change Password and Logout Buttons
                    VStack(spacing: 10) {
                        NavigationLink(destination: EditPasswordView(), isActive: $showChangePassword) {
                            EmptyView()
                        }
                        SettingButton(title: "Change Password", buttonColor: .appAstro, showArrow: true) {
                            showChangePassword = true
                        }

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
        print("UserSession cleared.")
        navigateToLogin = true
    }
}
#Preview {
    SettingsView()
}
