//
//  ErrorMessage.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/16/22.
//

import SwiftUI

struct ErrorMessage: View {
    /// The color of the text that
    let color: Color
    /// The message written by me that gives the user instructions for resolving an error.
    let message: String
    /// The localized description of the error that's shown to the user. Not written by me.
    let systemErrorText: String?
    
    init(color: Color = .primary, message: String, systemErrorText: String? = nil) {
        self.color = color
        self.message = message
        self.systemErrorText = systemErrorText
    }
    
    var body: some View {
        VStack {
            Text(message)
                .italic()
            
            if let systemErrorText {
                Text("System Error Message: \(systemErrorText)")
                    .italic()
            }
        }
        .foregroundColor(color)
        .multilineTextAlignment(.center)
    }
}

struct ErrorMessage_Previews: PreviewProvider {
    static var previews: some View {
        ErrorMessage(color: .black, message: "Loading Failed", systemErrorText: "Error Code 12356478364")
    }
}
