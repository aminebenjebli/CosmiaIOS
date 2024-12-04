import SwiftUI

struct EditPasswordView: View {
    @StateObject private var viewModel = UpdatePasswordViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            ZodiacAnimation2()
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Change Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)

                    VStack(alignment: .leading, spacing: 15) {
                        CustomTFields(sfIcon: "lock", hint: "Current Password", isPassword: true, value: $viewModel.currentPassword)
                            .textFieldStyleWhite()
                        CustomTFields(sfIcon: "lock", hint: "New Password", isPassword: true, value: $viewModel.newPassword)
                            .textFieldStyleWhite()
                        CustomTFields(sfIcon: "lock", hint: "Confirm New Password", isPassword: true, value: $viewModel.confirmNewPassword)
                            .textFieldStyleWhite()
                    }
                    .padding(.horizontal)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.callout)
                            .padding(.top)
                    }

                    if let passwordsDoNotMatchMessage = viewModel.passwordsDoNotMatchMessage {
                        Text(passwordsDoNotMatchMessage)
                            .foregroundColor(.red)
                            .font(.callout)
                            .padding(.top)
                    }

                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.callout)
                            .padding(.top)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    dismiss()
                                }
                            }
                    }

                    Button(action: {
                        viewModel.updatePassword()
                    }) {
                        if viewModel.isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save Changes")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isFormValid ? Color.orange : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .disabled(!viewModel.isFormValid || viewModel.isUpdating)

                    Spacer()
                }
                .padding()
            }
        }
    }
}

extension View {
    func textFieldStyleWhite1() -> some View {
        self
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            .foregroundColor(.white)
    }
}
