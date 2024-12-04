import SwiftUI

struct loginButton: View {
    var title: String
    var icon: String
    var onClick: () -> ()

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 15) {
                Text(title)
                Image(systemName: icon)
            }
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 35)
            .background(LinearGradient(colors: [.blue, .purple, .black], startPoint: .top, endPoint: .bottom))
            .clipShape(Capsule())
        }
    }
}

#Preview {
    loginButton(title: "Sign Up", icon: "arrow.right.circle") {}
}
