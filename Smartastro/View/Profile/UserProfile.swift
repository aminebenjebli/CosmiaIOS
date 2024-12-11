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
                        Image(viewModel.determineZodiacImage(from: viewModel.dateOfBirth))
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

                        Text("Date Of Birth : \(viewModel.dateOfBirth.formatted(.dateTime.month().day().year()))")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                        
                    }

                    HStack(spacing: 20) {
                        Button("Personal Info") {
                            showPersonalInfo = true
                        }
                        .buttonStyle(SmallInfoToggleStyle(isSelected: showPersonalInfo))
                        

                        Button("Settings") {
                            showPersonalInfo = false
                        }
                        .buttonStyle(SmallInfoToggleStyle(isSelected: !showPersonalInfo))
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
                            .background(Color.white)
                            .cornerRadius(10)
                            .accentColor(.white)
                            .opacity(0.6)
                            //Gender
                            CustomGender()
                                .opacity(0.6)
                            
                            Spacer().frame(height: 30)
                            
                            PreferencesView()
                            
                      

                            Button("Update Profile") {
                                updateViewModel.updateUser { success in
                                    alertMessage = success ? "Profile updated successfully." : "Failed to update profile."
                                    showAlert = true
                                }
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black]),startPoint: .top,endPoint: .bottom))
                            .foregroundColor(.yellow)
                            .cornerRadius(15)
                            .opacity(0.7)
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

struct SmallInfoToggleStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8) // Smaller vertical padding
            .padding(.horizontal, 12) // Smaller horizontal padding
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.appAstro.opacity(0.3) : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(10) // Smaller corner radius
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            
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
            .opacity(0.6)
    }
}

#Preview {
    NavigationStack {
        UserProfile(userId: "sampleUserId")
    }
}
//
//
//
