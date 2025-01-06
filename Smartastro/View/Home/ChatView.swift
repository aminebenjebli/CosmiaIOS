import SwiftUI

struct ChatView: View {
    @State private var messageInput: String = ""
    @ObservedObject var viewModel: ChatViewModel
    let receiverId: String
    let receiverUsername: String
    @StateObject var topicViewModel = TopicViewModel()
    @State private var showTopics: Bool = false

    var body: some View {
        VStack {
            ChatHeaderView(username: receiverUsername, receiverId: receiverId, viewModel: viewModel)
            MessagesListView(viewModel: viewModel)

            if showTopics {
                TopicSuggestionsView(viewModel: topicViewModel) { suggestion in
                    messageInput = suggestion
                    showTopics = false
                }
            }

            HStack {
                Button(action: {
                    showTopics.toggle()
                    if showTopics && topicViewModel.topics.isEmpty {
                        topicViewModel.fetchTopics()
                    }
                }) {
                    Image("logoCosmia") // Ensure this image exists in your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                InputBarView(messageInput: $messageInput, onSend: sendMessage)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.messages.isEmpty {
                if let roomId = viewModel.roomId {
                    viewModel.fetchMessages(roomId: roomId)
                } else {
                    viewModel.getOrCreateRoom(with: receiverId) { roomId in
                        if let roomId = roomId {
                            viewModel.fetchMessages(roomId: roomId)
                        } else {
                            print("Failed to create or fetch room")
                        }
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageInput.isEmpty else { return }
        viewModel.sendMessage(to: receiverId, content: messageInput)
        messageInput = ""
    }
}

struct TopicSuggestionsView: View {
    @ObservedObject var viewModel: TopicViewModel
    var onSuggestionSelected: (String) -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Suggestions")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Button("Refresh") {
                    viewModel.fetchTopics()
                }
                .padding(.trailing)
            }

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 10) {
                    ForEach(viewModel.topics, id: \.self) { topic in
                        Button(action: {
                            onSuggestionSelected(topic)
                        }) {
                            Text(topic)
                                .padding(15)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(nil) // Allow multi-line text
                                .fixedSize(horizontal: false, vertical: true) // Adjust height dynamically
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 150) // Adjust the height to show more content
        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

import SwiftUI

import SwiftUI

struct ChatHeaderView: View {
    var username: String
    var receiverId: String
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ChatViewModel
    @StateObject private var couplesViewModel = CouplesViewModel()
    @State private var showVideoCallView = false
    @State private var showPhoneCallView = false
    @State private var showCoupleRequest: Bool = false
    @State private var isRequestSending: Bool = false
    @State private var isLoadingCoupleStatus: Bool = false
    @State private var showGameView = false

    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.leading)
            }

            Spacer()

            if isLoadingCoupleStatus {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if couplesViewModel.isCouple {
                Button(action: {
                    showGameView = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Play Game")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding(6)
                    .background(Capsule().fill(Color.white))
                    .shadow(radius: 2)
                }
                .sheet(isPresented: $showGameView) {
                    ContentViewWrapper { score in
                        viewModel.sendMessage(to: receiverId, content: "I scored \(score) points in the game!")
                    }
                }
            } else if !couplesViewModel.eitherIsCoupled {
                Button(action: {
                    showCoupleRequest = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundColor(.pink)
                        Text("Become Couples")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                    }
                    .padding(6)
                    .background(Capsule().fill(Color.white))
                    .shadow(radius: 2)
                }
                .disabled(isRequestSending)
                .alert(isPresented: $showCoupleRequest) {
                    Alert(
                        title: Text("Become Couple"),
                        message: Text("Do you want to send a couple request to \(username)?"),
                        primaryButton: .default(Text("Yes")) {
                            sendCoupleRequest()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }

            Spacer()

            Text("Chat with \(username)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()

            Button(action: {
                showVideoCallView = true
                viewModel.sendCallMessage(to: receiverId, type: .video)
            }) {
                Image(systemName: "video.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.trailing)
            }
            .sheet(isPresented: $showVideoCallView) {
                VideoCallView(isPresented: $showVideoCallView, receiverName: username)
            }

            Button(action: {
                showPhoneCallView = true
                viewModel.sendCallMessage(to: receiverId, type: .phone)
            }) {
                Image(systemName: "phone.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .sheet(isPresented: $showPhoneCallView) {
                PhoneCallView(isPresented: $showPhoneCallView, receiverName: username)
            }
        }
        .padding()
        .background(Color.indigo)
        .onAppear {
            fetchCoupleStatus()
        }
    }

    private func fetchCoupleStatus() {
        isLoadingCoupleStatus = true
        let userId = SessionManager.shared.getActiveSession()?.userId ?? ""
        couplesViewModel.checkCoupleStatusForBoth(userId: userId, receiverId: receiverId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoadingCoupleStatus = false
        }
    }

    private func sendCoupleRequest() {
        isRequestSending = true
        let senderId = SessionManager.shared.getActiveSession()?.userId ?? ""
        couplesViewModel.sendCoupleRequest(senderId: senderId, receiverId: receiverId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isRequestSending = false
        }
    }
}

struct ContentViewWrapper: View {
    @Environment(\.presentationMode) var presentationMode
    var onGameEnd: (Int) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                ContentView1 { finalScore in
                    onGameEnd(finalScore) // Forward the score correctly
                    presentationMode.wrappedValue.dismiss()
                }
                VStack {
                    Spacer()
                    Button("Exit Game") {
                        onGameEnd(0) // Exit game with score 0 if user taps exit directly
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
struct MessagesListView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack(spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        if let content = message.content {
                            if content == "Started a video call" || content == "Started a phone call" {
                                CallMessageBubble(message: message, callType: content.contains("video") ? .video : .phone)
                            } else {
                                ChatBubble(message: message, isFromSender: message.senderId == SessionManager.shared.getActiveSession()?.userId)
                            }
                        }
                    }
                }
                .padding()
                .onChange(of: viewModel.messages) { _ in
                    if let lastMessage = viewModel.messages.last {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .padding()
    }
}

struct InputBarView: View {
    @Binding var messageInput: String
    var onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            TextField("Type a message...", text: $messageInput)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(messageInput.isEmpty ? Color.gray : Color.blue)
                    .padding(10)
                    .background(messageInput.isEmpty ? Color(.systemGray5) : Color.blue.opacity(0.2))
                    .clipShape(Circle())
            }
            .disabled(messageInput.isEmpty)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .background(Color(.secondarySystemBackground))
    }
}

struct CallMessageBubble: View {
    let message: Message
    let callType: CallType

    var body: some View {
        HStack {
            if callType == .video {
                Image(systemName: "video.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(message.content ?? "Unknown call")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "phone.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text(message.content ?? "Unknown call")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(callType == .video ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
        .cornerRadius(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
struct PhoneCallView: View {
    @Binding var isPresented: Bool
    let receiverName: String

    var body: some View {
        VStack {
            Spacer()
            Text("Calling \(receiverName)...")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.bottom, 50)
            Image(systemName: "phone.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding()
            Spacer()
            Button(action: {
                isPresented = false
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "phone.down.fill")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("End Call")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}

struct VideoCallView: View {
    @Binding var isPresented: Bool
    let receiverName: String

    var body: some View {
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    .overlay(
                        Text("Connecting to \(receiverName)...")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10),
                        alignment: .bottom
                    )
                Spacer()
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 120, height: 180)
                        .overlay(
                            VStack {
                                Text("Your Camera")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)
                                Image(systemName: "video.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white)
                            }
                        )
                        .padding(.trailing, 20)
                }
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "phone.down.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        Text("End Call")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.all)
        }
    }
}
