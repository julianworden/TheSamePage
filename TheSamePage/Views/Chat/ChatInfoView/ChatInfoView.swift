//
//  ChatInfoView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/7/22.
//

import SwiftUI

struct ChatInfoView: View {
    @StateObject var viewModel: ChatInfoViewModel
    
    init(chatParticipants: [ShowParticipant]) {
        _viewModel = StateObject(wrappedValue: ChatInfoViewModel(chatParticipants: chatParticipants))
    }
    
    var body: some View {
        List(viewModel.chatParticipants) { chatParticipant in
            // TODO: Add a section for show host by passing the show object into the chat
            Text(chatParticipant.name)
        }
        .listStyle(.grouped)
        .navigationTitle("Chat Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChatInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChatInfoView(chatParticipants: [])
    }
}
