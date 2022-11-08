//
//  ConversationView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import SwiftUI

struct ConversationView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    @StateObject var viewModel: ConversationViewModel
    
    @State private var sendButtonIsDisabled = true
    
    init(show: Show? = nil, userId: String? = nil, showParticipants: [ShowParticipant]) {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(show: show, userId: userId, showParticipants: showParticipants))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(chatMessage: message)
                        }
                    }
                }
                // Needed to prevent ScrollView from going behind the navigation bar. I don't know why
                .padding(.top, 0.5)
                
                Spacer()
                
                HStack {
                    TextField("Message", text: $viewModel.messageText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        Task {
                            await viewModel.sendChatMessage(fromUser: loggedInUserController.loggedInUser)
                            viewModel.messageText = ""
                        }
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .disabled(sendButtonIsDisabled)
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ChatInfoView(chatParticipants: viewModel.showParticipants)
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .task {
            await viewModel.configureChat()
            viewModel.addChatListener()
        }
        .onChange(of: viewModel.messageText) { messageText in
            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sendButtonIsDisabled = false
            } else {
                sendButtonIsDisabled = true
            }
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(show: Show.example, showParticipants: [])
    }
}
