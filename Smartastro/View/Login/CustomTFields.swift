import SwiftUI

struct CustomTFields: View {
    var sfIcon: String
    var iconTint: Color = .purple
    var hint: String
    var isPassword: Bool = false
    @Binding var value: String
    @State private var showPassword: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: sfIcon)
                .foregroundStyle(iconTint)
                .frame(width: 30)
                .offset(y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                if isPassword {
                    Group {
                        if showPassword {
                            TextField(hint, text: $value)
                        } else {
                            SecureField(hint, text: $value)
                        }
                    }
                } else {
                    TextField(hint, text: $value)
                }
                Divider()
            }
            .overlay(alignment: .trailing) {
                if isPassword {
                    Button(action: {
                        withAnimation {
                            showPassword.toggle()
                        }
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.gray)
                            .padding(10)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }
}

#Preview {
    CustomTFields(sfIcon: "at", hint: "Email", value: .constant(""))
    CustomTFields(sfIcon: "lock", hint: "password", value: .constant(""))
    CustomTFields(sfIcon: "lock", hint: "Confirm Password", value: .constant(""))
}
