//
//  ChatBubble.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/4/22.
//

import SwiftUI

struct ChatBubble: View {
    let senderIsLoggedInUser: Bool
    let chatMessage: ChatMessage
    
    init(chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
        self.senderIsLoggedInUser = chatMessage.senderIsLoggedInUser
    }
    
    var body: some View {
        HStack {
            if senderIsLoggedInUser {
                Spacer()
            }
            
            VStack(alignment: senderIsLoggedInUser ? .trailing : .leading, spacing: 3) {
                HStack {
                    if senderIsLoggedInUser {
                        Spacer()
                    }
                    
                    Text(chatMessage.senderFullName)
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(senderIsLoggedInUser ? .trailing : .leading)
                    
                    if !senderIsLoggedInUser {
                        Spacer()
                    }
                }
                
                VStack(alignment: senderIsLoggedInUser ? .trailing : .leading) {
                    Text(chatMessage.text)
                        
                    Text(chatMessage.sentTimestampAsDate.timeAndDate)
                        .font(.caption2)
                }
                .foregroundColor(.white)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10, corners: roundedCorners)
            }
            
            if !senderIsLoggedInUser {
                Spacer()
            }
        }
    }
    
    var roundedCorners: UIRectCorner {
        if senderIsLoggedInUser {
            return [.topLeft, .topRight, .bottomLeft]
        } else {
            return [.topLeft, .topRight, .bottomRight]
        }
    }
    
    var backgroundColor: Color {
        if senderIsLoggedInUser {
            return .accentColor
        } else {
            return .gray
        }
    }
}

struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubble(chatMessage: ChatMessage.example)
    }
}
