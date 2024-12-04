import SwiftUI

struct Login: View {
    @StateObject private var viewModel = LoginViewModel()
    @Binding var showSignup: Bool
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showForgetPassword: Bool = false
    @State private var showResetView: Bool = false
    @State private var askOtp: Bool = false
    @State private var otpText: String = ""
    @State private var showNextView: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showPopup: Bool = false

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            // Zodiac Animation Layer
            ZodiacAnimation()
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                Spacer(minLength: 0)
                Text("Welcome Back")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .fontWeight(.heavy)

                Text("Please sign in to continue")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, -5)

                VStack(spacing: 25) {
                    CustomTFields(sfIcon: "at", hint: "Email", value: $viewModel.emailId)
                        .textFieldStyle()
                    if viewModel.emailEdited && !viewModel.emailIsValid {
                        Text("Please enter a valid email address")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.leading, 5)
                    }

                    CustomTFields(sfIcon: "lock", hint: "Password", isPassword: true, value: $viewModel.password)
                        .textFieldStyle()
                        .padding(.top, 5)

                    if viewModel.passwordEdited && !viewModel.passwordIsValid {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Password must be at least 8 characters.")
                            Text("Contain an uppercase letter and a digit.")
                        }
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.leading, 5)
                    }

                    Button("Forget Password") {
                        if viewModel.emailIsValid {
                            viewModel.forgetPassword { success in
                                if success {
                                    errorMessage = "A temporary password has been sent to your email."
                                    showSuccessAlert = true
                                } else {
                                    errorMessage = "Unable to process request. Try again."
                                    showError = true
                                }
                            }
                        } else {
                            errorMessage = "Please enter a valid email."
                            showError = true
                        }
                    }
                    .font(.callout)
                    .fontWeight(.heavy)
                    .tint(.white)
                    .hSpacing(.trailing)

                    loginButton(title: "Login", icon: "arrow.right") {
                        viewModel.loginUser { status in
                            switch status {
                            case .otpRequired:
                                askOtp = true
                                viewModel.sendOtp()
                            case .success:
                                viewModel.checkAccountStatus { isVerified in
                                    if isVerified {
                                        DispatchQueue.main.async {
                                            showNextView = true
                                        }
                                    } else {
                                        errorMessage = "Account verification failed."
                                        showError = true
                                    }
                                }
                            case .accountDoesNotExist:
                                errorMessage = "Account does not exist."
                                showPopupMessage(error: errorMessage)
                            case .error:
                                errorMessage = "Email or password is incorrect. Try again."
                                showPopupMessage(error: errorMessage)
                            }
                        }
                    }
                    .displayWithOpacity(viewModel.isLoginButtonDisabled)
                }
                .padding(.top, 20)

                Spacer(minLength: 0)
                HStack(spacing: 6) {
                    Text("Don't have an account?")
                        .foregroundStyle(.white.opacity(0.8))
                    Button("Sign Up") {
                        showSignup.toggle()
                    }
                    .fontWeight(.bold)
                    .tint(.white)
                }
                .font(.callout)
                .hSpacing()
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 25)
            .toolbar(.hidden, for: .navigationBar)

            .sheet(isPresented: $askOtp) {
                OTPView(otpText: $otpText, showResetView: $showResetView, showNextView: $showNextView, viewModel: viewModel)
                    .presentationDetents([.height(350)])
                    .presentationCornerRadius(30)
            }

            .sheet(isPresented: $showResetView) {
                ResetPasswordView(showResetView: $showResetView)
                    .presentationDetents([.height(350)])
                    .presentationCornerRadius(30)
            }

            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Success"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }

            .fullScreenCover(isPresented: $showNextView) {
                HomeView()
            }

            if showPopup {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showPopup)
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showPopup = false
                            }
                        }
                    }
            }
        }
    }

    private func showPopupMessage(error: String) {
        errorMessage = error
        withAnimation {
            showPopup = true
        }
    }
}

struct ZodiacAnimation: View {
    let zodiacSigns = ["♈︎", "♉︎", "♊︎", "♋︎", "♌︎", "♍︎", "♎︎", "♏︎", "♐︎", "♑︎", "♒︎", "♓︎"]
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<zodiacSigns.count, id: \.self) { index in
                Text(zodiacSigns[index])
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.7))
                    .rotationEffect(.degrees(rotation))
                    .offset(x: 0, y: -150)
                    .rotationEffect(.degrees(Double(index) * 30))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

extension View {
    func textFieldStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}
#Preview(){
    Login(showSignup: .constant(false))
    
}
