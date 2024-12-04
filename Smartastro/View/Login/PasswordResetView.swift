//
//  PasswordResetView.swift
//  user-down
//
//  Created by AmineBj on 11/6/24.
//

import SwiftUI

struct ResetPasswordView: View {
    @Binding var showResetView: Bool
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                showResetView = false  // Dismiss the Reset Password view
            }, label: {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundStyle(.gray)
            })
            .padding(.top, 15)
            
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top, 5)
            
            VStack(spacing: 25) {
                // Custom text fields for new password and confirm password
                CustomTFields(sfIcon: "lock", hint: "New Password", value: $newPassword)
                CustomTFields(sfIcon: "lock", hint: "Confirm Password", value: $confirmPassword)
                
                // Submit Button
                loginButton(title: "Reset Password", icon: "checkmark") {
                    // Handle password reset logic here
                    // After reset, you can navigate to a success screen or dismiss
                    showResetView = false
                }
                .displayWithOpacity(newPassword.isEmpty || confirmPassword.isEmpty)
            }
            .padding(.top, 20)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .interactiveDismissDisabled()
    }
}


#Preview {
    ContentView()
}
