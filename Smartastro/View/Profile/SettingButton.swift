import SwiftUI

struct SettingButton: View {
    let title: String
    let buttonColor: Color
    let showArrow: Bool
    let action: () -> Void

    init(title: String, buttonColor: Color = .gray, showArrow: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.buttonColor = buttonColor
        self.showArrow = showArrow
        self.action = action
    }

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isPressed ? buttonColor.opacity(0.4) : buttonColor.opacity(0.2))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle()) // To avoid default button styling
        .accessibilityLabel("\(title) button")
    }
}

#Preview {
    VStack {
        SettingButton(title: "Change password", buttonColor: .blue, showArrow: true) {
            print("Navigating to About Us...")
        }
        SettingButton(title: "Logout", buttonColor: .red, showArrow: false) {
            print("Logging out...")
        }
    }
    .padding()
}
