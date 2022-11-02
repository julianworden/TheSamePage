//
//  NoDataFoundMessage.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import SwiftUI

/// Used for telling a user when they do not have certain information in the app. For example, if a user
/// has no band invites, they will see a message constructed by this view.
struct NoDataFoundMessage: View {
    let message: String
    
    var body: some View {
        Text(message)
            .italic()
            .padding()
    }
}

struct NoDataFoundMessage_Previews: PreviewProvider {
    static var previews: some View {
        NoDataFoundMessage(message: "You do not have any pending notifications.")
    }
}
