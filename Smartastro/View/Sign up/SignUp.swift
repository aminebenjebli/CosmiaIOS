import SwiftUI

struct SignUp: View {
    @ObservedObject var viewModel: SignUpViewModel
    @Binding var showSignup: Bool
    @State private var showDatePicker = false

    init(showSignup: Binding<Bool>) {
        self._showSignup = showSignup
        self.viewModel = SignUpViewModel(showSignup: showSignup)
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            ZodiacAnimation()
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Button(action: {
                        showSignup = false
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 10)
                    .navigationBarBackButtonHidden(true)

                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                        .padding(.leading, 20)

                    Text("Please sign up to continue")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, -5)
                        .padding(.leading, 20)

                    VStack(spacing: 15) {
                        CustomTFields(sfIcon: "at", hint: "Email", value: $viewModel.emailId)
                            .textFieldStyle()
                        if viewModel.emailEdited && !viewModel.emailIsValid {
                            Text("Please enter a valid email.")
                                .foregroundColor(.red)
                                .font(.callout)
                                .padding(.leading, 5)
                        }

                        CustomTFields(sfIcon: "person", hint: "Full Name", value: $viewModel.userName)
                            .textFieldStyle()

                        CustomTFields(sfIcon: "lock", hint: "Password", isPassword: true, value: $viewModel.password)
                            .textFieldStyle()
                        if viewModel.passwordEdited && !viewModel.passwordIsValid {
                            Text("Password must be at least 8 characters, 1 uppercase letter, and 1 digit.")
                                .foregroundColor(.red)
                                .font(.callout)
                                .padding(.leading, 5)
                        }

                        CustomTFields(sfIcon: "lock", hint: "Confirm Password", isPassword: true, value: $viewModel.confirmPassword)
                            .textFieldStyle()
                        if viewModel.confirmPasswordEdited && !viewModel.confirmPasswordIsValid {
                            Text("Passwords do not match.")
                                .foregroundColor(.red)
                                .font(.callout)
                                .padding(.leading, 5)
                        }

                        VStack {
                            Button(action: {
                                withAnimation {
                                    showDatePicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text(viewModel.birthDateFormatted)
                                        .font(.body)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                            }

                            if showDatePicker {
                                DatePicker(
                                    "Select your birthday",
                                    selection: $viewModel.birthDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .frame(maxHeight: 400)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .accentColor(.white)
                            }
                        }

                        loginButton(title: "Sign Up", icon: "arrow.right.circle") {
                            viewModel.signUpUser()
                        }
                        .disabled(viewModel.isSignUpButtonDisabled)
                        .opacity(viewModel.isSignUpButtonDisabled ? 0.5 : 1)

                        Spacer(minLength: 0)

                        HStack(spacing: 6) {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.8))
                            NavigationLink(destination: Login(showSignup: .constant(false))) {
                                Text("Login")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .font(.callout)
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 25)
                }
                .padding(.bottom, 20)
            }

            if viewModel.showSuccessPopup {
                SuccessPopup(message: "Signup Successful!")
                    .transition(.scale)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: viewModel.showSuccessPopup)
    }
}

struct SuccessPopup: View {
    var message: String

    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 50))
                .padding(.bottom, 10)

            Text(message)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
        }
        .frame(width: 250, height: 150)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct ZodiacAnimation1: View {
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
    func textFieldStyle1() -> some View {
        self
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            .foregroundColor(.white)
    }
}

#Preview {
    SignUp(showSignup: .constant(true))
}
