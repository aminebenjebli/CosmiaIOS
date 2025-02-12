# Cosmia - A Zodiac-Based Social App

## Overview
Cosmia is an innovative social networking application that blends astrology with advanced technology to connect people through shared zodiac compatibility. Users can explore daily horoscopes, share stories, and interact with their matches.

## Table of Contents
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Roadmap](#roadmap)
- [Contribution](#contribution)
- [License](#license)

## Features
1. **Matchmaking Based on Zodiac Compatibility**
   - Swipe through profiles with zodiac details.
   - Match with users based on zodiac compatibility or similar traits.
   - Interactive "It's a Match" animations for confirmed connections.

2. **Daily Horoscope (AI-Powered)**
   - Get personalized daily horoscopes for each zodiac sign.
   - AI-generated visual horoscopes using ChatGPT and DALL·E.
   - Save and view the history of your horoscopes in a dedicated section.

3. **Stories**
   - Share stories with your followers or view stories shared by others.
   - Comment on stories and interact with matched users.
   - Auto-advance through multiple stories seamlessly.

4. **Chat with Matches**
   - Real-time chat with matched users.
   - Comment on their shared stories directly from the chat interface.
   - Send couple requests and engage in fun couple-specific activities.

5. **User Albums**
   - Upload and display albums to share your favorite moments.
   - Set a profile picture from your album.
   - View albums of matched users directly in their profiles.

6. **Story Bar**
   - Organized story feed with user-specific categories.
   - Tap on a user's story to view and comment.

7. **Zodiac History**
   - Access a timeline of your past daily horoscopes.
   - Explore how your astrological predictions evolved over time.
   - Compare your horoscope history with friends or matches.

## Technologies Used
### Frontend
- **SwiftUI (iOS)**: Intuitive UI design with seamless user interaction.
- **Combine Framework**: Efficient asynchronous programming.

### Backend
- **NestJS**: A scalable and reliable REST API.
- **MongoDB**: Database to manage user data, stories, chats, and horoscope history.

### AI Integration
- **ChatGPT API**: Provides daily horoscope text based on zodiac signs.
- **DALL·E API**: Generates stunning visual representations of daily horoscopes.

### Authentication
- **JWT**: Token-based authentication for secure login and sessions.

### Media Management
- **Image Loading and Caching**: Asynchronous image loading and caching for albums and stories.

## Architecture
The project follows an MVVM (Model-View-ViewModel) architecture for better separation of concerns and scalability. The structure is as follows:

```
Smartastro/
│── SmartastroApp.swift  # Entry point of the app
│── Persistence/          # Persistence layer (e.g., CoreData, UserDefaults)
│── Info/                # Configuration files and app metadata
│── Assets/              # Image, font, and other resource files
│── Model/               # Data models representing app entities
│── ViewModel/           # ViewModel layer handling logic between Model and View
│── View/                # UI components following SwiftUI principles
│   ├── Home/
│   ├── Login/
│   ├── Profile/
│   ├── Settings/
│   ├── SignUp/
│   ├── Stories/
│   ├── cosmiagame/
│── Helper/              # Utility functions and helper extensions
│── font/                # Custom fonts for the UI
│── Preview Content/      # Xcode Previews for UI development
```

### MVVM Breakdown:
- **Model:** Represents the app's data layer, including API responses and local database models.
- **ViewModel:** Acts as an intermediary between the Model and View, ensuring data binding and business logic execution.
- **View:** Handles the presentation layer, including SwiftUI components for user interaction.

## Getting Started
To get a local copy up and running, follow these steps:

1. **Clone the repository**
    ```sh
    git clone https://github.com/aminebenjebli/CosmiaIOS.git
    ```

2. **Navigate to the project directory**
    ```sh
    cd CosmiaIOS
    ```

3. **Install dependencies**
    ```sh
    pod install
    ```

4. **Open the project in Xcode**
    ```sh
    open CosmiaIOS.xcworkspace
    ```

5. **Run the application**
    - Select a target device or simulator.
    - Click the "Run" button in Xcode.

## Roadmap
Planned Features:
- Astrology Games: Fun interactive games for zodiac signs.
- Story Reactions: Like and react to stories with emojis.
- Horoscope Sharing: Share your daily horoscope as a story or with matches.
- Voice and Video Chats: Add real-time communication with matches.

## Contribution
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
Distributed under the MIT License. See `LICENSE` for more information.

