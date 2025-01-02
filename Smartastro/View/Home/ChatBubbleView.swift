import SwiftUI

struct ChatBubble: View {
    let message: Message
    let isFromSender: Bool

    var body: some View {
        HStack {
            if isFromSender {
                Spacer()
                if let content = message.content {
                    Text(content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                }
                Text(message.createdAtFormatted)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        if let content = message.content {
                            Text(content)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundColor(.black)
                                .cornerRadius(20)
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                        }
                        Spacer()
                    }
                    Text(message.createdAtFormatted)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

extension Message {
    var createdAtFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let date = ISO8601DateFormatter().date(from: createdAt) else { return "" }
        return formatter.string(from: date)
    }
}
