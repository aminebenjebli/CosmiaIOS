import SwiftUI

struct PreferencesView: View {
    @State private var showModal = false
    @State private var selectedPreferences: Set<String> = []
    
    // List of preferences
    let preferences = ["Sports", "Music", "Football", "Gym", "Reading", "Movies", "Travel", "Technology", "Art"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Display selected preferences
            Text("Selected preferences:")
                .font(.headline)
                .foregroundColor(.gray)
            
            if !selectedPreferences.isEmpty {
                Text(displaySelectedPreferences())
                    .font(.body)
                    .foregroundColor(.black)
                    .italic()
            } else {
                Text("None")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            // Add Preferences Button
            Button(action: {
                withAnimation {
                    showModal.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.body)
                        .foregroundColor(.black)
                    Text("Add preferences")
                        .font(.body)
                        .foregroundColor(.black)
                }
                .padding(.vertical, 12) // Adjust padding for height
                .frame(maxWidth: .infinity) // Stretch button width
                .frame(height: 44) // Match height of other fields
                .background(Color.clear) // Remove the background color
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            .padding(.top, 5) // Reduce top padding to align vertically with other fields

            // Modal View
            if showModal {
                ZStack {
                    // Background overlay
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showModal = false // Close modal when tapping outside
                            }
                        }
                    
                    VStack {
                        Text("Select Preferences")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .bold()
                            .padding(.bottom, 20)
                        
                        // Preferences grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                            ForEach(preferences, id: \.self) { preference in
                                Button(action: {
                                    toggleSelection(for: preference)
                                }) {
                                    Text(preference)
                                        .font(.body)
                                        .padding(12)
                                        .background(selectedPreferences.contains(preference) ? Color.indigo : Color.gray.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedPreferences.contains(preference) ? Color.indigo : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Done Button
                        Button(action: {
                            withAnimation {
                                showModal = false
                            }
                        }) {
                            Text("Done")
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.indigo)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    .frame(width: 350, height: 450)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 15)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
    }
    
    // Toggle selection for preferences
    private func toggleSelection(for preference: String) {
        if selectedPreferences.contains(preference) {
            selectedPreferences.remove(preference)
        } else {
            selectedPreferences.insert(preference)
        }
    }
    
    // Display selected preferences as a comma-separated string
    private func displaySelectedPreferences() -> String {
        let preferencesArray = Array(selectedPreferences)
        if preferencesArray.isEmpty {
            return "None"
        }
        return preferencesArray.joined(separator: ", ")
    }
}


#Preview {
    PreferencesView()
}
