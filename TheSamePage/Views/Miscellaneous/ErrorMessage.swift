//
//  ErrorMessage.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/16/22.
//

import SwiftUI

struct ErrorMessage: View {
    let color: Color
    let message: String
    let errorText: String
    
    init(color: Color = .primary, message: String, errorText: String) {
        self.color = color
        self.message = message
        self.errorText = errorText
    }
    
    var body: some View {
        VStack {
            Text(message)
                .italic()
                .foregroundColor(color)
            
            Text("Error: \(errorText)")
                .italic()
                .foregroundColor(color)
        }
        .multilineTextAlignment(.center)
    }
}

struct ErrorMessage_Previews: PreviewProvider {
    static var previews: some View {
        ErrorMessage(color: .black, message: "Loading Failed", errorText: "Error Code 12356478364")
    }
}
