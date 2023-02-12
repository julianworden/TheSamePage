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
    
    init(show: Show? = nil, userId: String? = nil, chatParticipantUids: [String]) {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(show: show, userId: userId, chatParticipantUids: chatParticipantUids))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()

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
                        TextField("Message", text: $viewModel.messageText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)

                        AsyncButton {
                            await viewModel.sendMessageButtonTapped(by: loggedInUserController.loggedInUser)
                        } label: {
                            Image(systemName: "arrow.up")
                        }
                        .disabled(viewModel.sendButtonIsDisabled)
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ChatInfoView(show: viewModel.show, chatParticipantUids: viewModel.chatParticipantUids)
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText,
                tryAgainAction: viewModel.callOnAppearMethods
            )
            .task {
                await viewModel.callOnAppearMethods()
            }
            .onChange(of: viewModel.messageText) { messageText in
                if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    viewModel.sendButtonIsDisabled = false
                } else {
                    viewModel.sendButtonIsDisabled = true
                }
            }
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(show: Show.example, chatParticipantUids: [])
    }
}
