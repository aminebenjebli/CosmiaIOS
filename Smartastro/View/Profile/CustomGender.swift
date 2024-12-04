import SwiftUI

struct CustomGender: View {
    @State private var selectedGender: String = "Select Gender"
    @State private var showDropdown: Bool = false
    let genders = ["Male", "Female", "Non-Binary", "Other"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .top) {
                // Main button to toggle dropdown
                Button(action: {
                    withAnimation {
                        showDropdown.toggle()
                    }
                }) {
                    HStack {
                        Text(selectedGender)
                            .foregroundColor(selectedGender == "Select Gender" ? .gray : .purple)
                        Spacer()
                        Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }

                // Dropdown menu
                if showDropdown {
                    VStack(spacing: 0) {
                        ForEach(genders, id: \.self) { gender in
                            Button(action: {
                                withAnimation {
                                    selectedGender = gender
                                    showDropdown = false
                                }
                            }) {
                                Text(gender)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .background(Color.purple)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .offset(y: 60) // Adjusted offset to avoid overlapping
                }
            }
            .background(Color.clear)
        }
        .padding()
    }
}

#Preview {
    CustomGender()
}
