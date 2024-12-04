import SwiftUI

struct PreferencesView: View {
    @State private var showModal = false
    @State private var selectedPreferences: Set<String> = []
    
    // List of preferences
    let preferences = ["Sports", "Music", "Football", "Gym", "Reading", "Movies", "Travel", "Technology", "Art"]
    
    var body: some View {
        VStack {
            // Displaying selected preferences, showing up to 2 and appending "..." if there are more
            HStack {
                Text("Selected Preferences: ")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(displaySelectedPreferences())
                    .foregroundColor(.gray)
                    .italic()
            }
            .padding(.top)
            
            // Button to show modal
            Button(action: {
                showModal.toggle()
            }) {
                Text("+ Add Preferences")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            // Modal View
            if showModal {
                ZStack {
                    // Background overlay
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showModal = false // Close modal when tapping outside
                        }
                    
                    VStack {
                        Text("Select Preferences")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .bold()
                            .padding(.bottom, 20)
                        
                        // Buttons arranged in a grid of 3 per row
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                            ForEach(preferences, id: \.self) { preference in
                                Button(action: {
                                    toggleSelection(for: preference)
                                }) {
                                    Text(preference)
                                        .font(.body)
                                        .padding(12)
                                        .background(selectedPreferences.contains(preference) ? Color.purple : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedPreferences.contains(preference) ? Color.purple : Color.gray.opacity(0.6), lineWidth: 2)
                                        )
                                        .scaleEffect(selectedPreferences.contains(preference) ? 1.05 : 1)
                                        .animation(.easeInOut(duration: 0.2), value: selectedPreferences)
                                }
                                .frame(height: 50)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Done button
                        Button(action: {
                            showModal = false
                        }) {
                            Text("Done")
                                .font(.body)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 20)
                    }
                    .frame(width: 350, height: 450)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 15)
                }
            }
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
    }
    
    // Toggle selection of preference
    private func toggleSelection(for preference: String) {
        if selectedPreferences.contains(preference) {
            selectedPreferences.remove(preference)
        } else {
            selectedPreferences.insert(preference)
        }
    }
    
    // Display up to two selected preferences, appending "..." if there are more
    private func displaySelectedPreferences() -> String {
        let preferencesArray = Array(selectedPreferences)
        if preferencesArray.count > 2 {
            return preferencesArray.prefix(2).joined(separator: ", ") + "..."
        } else {
            return preferencesArray.joined(separator: ", ")
        }
    }
}

#Preview {
    PreferencesView()
}
