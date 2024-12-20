import SwiftUI

struct ChatView: View {
    @State private var messageInput: String = ""
    @ObservedObject var viewModel: ChatViewModel
    let receiverId: String
    let receiverUsername: String
    
    var body: some View {
        VStack {
            ChatHeaderView(username: receiverUsername)
            MessagesListView(viewModel: viewModel)
            InputBarView(messageInput: $messageInput, onSend: sendMessage)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if viewModel.messages.isEmpty {
                viewModel.fetchMessages(with: receiverId)
            }
        }
    }
    
    private func sendMessage() {
        guard !messageInput.isEmpty else { return }
        viewModel.sendMessage(to: receiverId, content: messageInput)
        messageInput = ""
    }
}

struct ChatHeaderView: View {
    var username: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss() // Dismiss the current view
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.leading)
            }
            Spacer()
            Text("Chat with \(username)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color.indigo)
    }
}

struct MessagesListView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack(spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message, isFromSender: message.senderId == SessionManager.shared.getActiveSession()?.userId)
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
