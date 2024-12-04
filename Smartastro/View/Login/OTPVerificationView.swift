import SwiftUI

struct OTPVerificationView: View {
    // View properties
    @Binding var otpText: String
    // Keyboard state
    @FocusState private var isKeyboardShowing: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { index in
                OTPTextBox(index)
            }
        }
        .background {
            TextField("", text: $otpText.limit(6)) // Ensure 6-character OTP
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0)
                .focused($isKeyboardShowing)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing = true
        }
    }
    
    // MARK: OTP Text Box
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.gray, lineWidth: 0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: Binding<String> Extension
extension Binding where Value == String {
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}
