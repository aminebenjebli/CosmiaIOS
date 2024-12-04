import SwiftUI

struct UserProfile: View {
    @StateObject var viewModel: UserProfileViewModel
    @StateObject var updateViewModel: UpdateViewModel
    @State private var showPersonalInfo = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedGender: String = "Select Gender"
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(userId: userId))
        _updateViewModel = StateObject(wrappedValue: UpdateViewModel(userId: userId))
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            ZodiacAnimation()
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(determineZodiacImage(from: viewModel.dateOfBirth))
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())

                        Text(viewModel.username)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(viewModel.email)
                            .font(.subheadline)
                            .foregroundColor(.white)

                        Text("DOB: \(viewModel.dateOfBirth.formatted(.dateTime.month().day().year()))")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                    }

                    HStack(spacing: 50) {
                        Button("Personal Info") {
                            showPersonalInfo = true
                        }
                        .buttonStyle(InfoToggleStyle(isSelected: showPersonalInfo))

                        Button("Settings") {
                            showPersonalInfo = false
                        }
                        .buttonStyle(InfoToggleStyle(isSelected: !showPersonalInfo))
                    }

                    if showPersonalInfo {
                        VStack(spacing: 20) {
                            //username
                            CustomTFields(sfIcon: "person.crop.circle", hint: "Username", value: $updateViewModel.username)
                                .textFieldStyleWhite()
                            //email
                            CustomTFields(sfIcon: "envelope.fill", hint: "Email", value: $updateViewModel.email)
                                .textFieldStyleWhite()
                            //date of birth
                            DatePicker(
                                "Date of Birth",
                                selection: $updateViewModel.dateOfBirth,
                                displayedComponents: .date
                            )
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .accentColor(.white)
                            //Gender
                            CustomGender()
                            Spacer()

                            Button("Update Profile") {
                                updateViewModel.updateUser { success in
                                    alertMessage = success ? "Profile updated successfully." : "Failed to update profile."
                                    showAlert = true
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.appAstro)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    } else {
                        SettingsView()
                            .padding()
                    }

                    Spacer()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Update Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func determineZodiacImage(from date: Date) -> String {
        let zodiacImages = [
            ("capricorn", (start: "12-22", end: "01-19")),
            ("aquarius", (start: "01-20", end: "02-18")),
            ("pisces", (start: "02-19", end: "03-20")),
            ("aries", (start: "03-21", end: "04-19")),
            ("taurus", (start: "04-20", end: "05-20")),
            ("gemini", (start: "05-21", end: "06-20")),
            ("cancer", (start: "06-21", end: "07-22")),
            ("leo", (start: "07-23", end: "08-22")),
            ("virgo", (start: "08-23", end: "09-22")),
            ("libra", (start: "09-23", end: "10-22")),
            ("scorpio", (start: "10-23", end: "11-21")),
            ("sagittarius", (start: "11-22", end: "12-21"))
        ]

        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"

        let dateString = formatter.string(from: date)
        let dateComponents = dateString.split(separator: "-").map { Int($0)! }

        for (image, range) in zodiacImages {
            let startComponents = range.start.split(separator: "-").map { Int($0)! }
            let endComponents = range.end.split(separator: "-").map { Int($0)! }

            if (dateComponents[0] == startComponents[0] && dateComponents[1] >= startComponents[1]) ||
                (dateComponents[0] == endComponents[0] && dateComponents[1] <= endComponents[1]) ||
                (startComponents[0] < endComponents[0] && (dateComponents[0] > startComponents[0] && dateComponents[0] < endComponents[0])) {
                return image
            }
        }

        return "aries"
    }
}

struct ZodiacAnimation2: View {
    let zodiacImages = ["capricorn", "aquarius", "pisces", "aries", "taurus", "gemini", "cancer", "leo", "virgo", "libra", "scorpio", "sagittarius"]
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<zodiacImages.count, id: \.self) { index in
                Image(zodiacImages[index])
                    .resizable()
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .offset(x: 0, y: -150)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct InfoToggleStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.appAstro : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

extension View {
    func textFieldStyleWhite() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            .foregroundColor(.black)
    }
}

#Preview {
    NavigationStack {
        UserProfile(userId: "sampleUserId")
    }
}
