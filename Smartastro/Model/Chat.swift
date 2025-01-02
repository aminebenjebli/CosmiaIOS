//
//  Chat.swift
//  Smartastro
//
//  Created by Aziz on 12/30/24.
//

import Foundation


// Chat Model
struct Chat: Identifiable, Codable {
    var id: String { messageId } 
    let messageId: String
    let roomId: String
    let senderId: String
    let receiverId: String
    let message: String
    let timestamp: Date
}

// Agora Token Models
struct AgoraRtmToken: Codable {
    let token: String
}

struct AgoraRtcToken: Codable {
    let token: String
}

// Room Model
struct ChatRoom: Codable {
    let roomId: String
}
