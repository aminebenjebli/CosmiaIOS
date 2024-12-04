import SwiftUI

struct OTPView: View {
    @Binding var otpText: String
    @Binding var showResetView: Bool
    @Binding var showNextView: Bool
    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var resendDisabled = true
    @State private var countdown = 60

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                dismiss() // Dismiss current sheet
            }, label: {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundStyle(.gray)
            })
            .padding(.top, 15)

            Text("Enter OTP")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top, 5)

            Text("A 6-digit code has been sent to your email.")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)

            VStack(spacing: 25) {
                OTPVerificationView(otpText: $otpText)

                loginButton(title: "Verify", icon: "arrow.right") {
                    viewModel.verifyOtp(otp: otpText) { success in
                        if success {
                            dismiss() // Ensure the current modal is dismissed
                            showNextView = true // Navigate to the next view after dismissal
                        } else {
                            viewModel.errorMessage = "Invalid or expired OTP."
                            viewModel.showError = true
                        }
                    }
                }
                .displayWithOpacity(otpText.isEmpty)

                if resendDisabled {
                    Text("Resend OTP in \(countdown) seconds")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                } else {
                    Button("Resend OTP") {
                        viewModel.sendOtp()
                        startCountdown()
                    }
                    .font(.callout)
                    .foregroundStyle(.blue)
                }
            }
        }
        .onAppear(perform: startCountdown)
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showNextView) {
            HomeView() // Replace this with the destination view.
        }
    }

    private func startCountdown() {
        resendDisabled = true
        countdown = 60
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdown -= 1
            if countdown == 0 {
                resendDisabled = false
                timer.invalidate()
            }
        }
    }
}
