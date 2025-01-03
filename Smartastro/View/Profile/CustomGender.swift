import SwiftUI

struct CustomGender: View {
    @Binding var selectedGender: String // Binding to parent view's gender property
    @State private var showDropdown: Bool = false
    let genders = ["Male", "Female", "Non-Binary", "Other"]
    let genderIcons = ["Male": "person.fill", "Female": "person.fill", "Non-Binary": "person.2.fill", "Other": "questionmark.circle"]

    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: {
                withAnimation {
                    showDropdown.toggle()
                }
            }) {
                HStack {
                    if let icon = genderIcons[selectedGender] {
                        Image(systemName: icon)
                            .foregroundColor(.gray)
                            .frame(width: 20, height: 20)
                    }
                    Text(selectedGender)
                        .foregroundColor(selectedGender == "Select Gender" ? .gray : .black)
                    Spacer()
                    Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            }

            if showDropdown {
                VStack(spacing: 0) {
                    ForEach(genders, id: \.self) { gender in
                        Button(action: {
                            withAnimation {
                                selectedGender = gender
                                showDropdown = false
                            }
                        }) {
                            HStack {
                                Image(systemName: genderIcons[gender] ?? "questionmark.circle")
                                    .foregroundColor(.gray)
                                    .frame(width: 20, height: 20)
                                Text(gender)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                .offset(y: 55)
            }
        }
        .zIndex(1)
    }
}

