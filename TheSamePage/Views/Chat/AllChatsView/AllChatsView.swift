//
//  AllChatsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/22/23.
//

import SwiftUI

struct AllChatsView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var loggedInUserController: LoggedInUserController

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()

                ScrollView {
                    VStack(spacing: UiConstants.listRowSpacing) {
                        ForEach(Array(loggedInUserController.allUserChats.enumerated()), id: \.element) { index, chat in
                            NavigationLink {
                                ConversationView(chat: chat, chatParticipantUids: chat.participantUids)
                            } label: {
                                ChatRow(index: index)
                            }
                            .tint(.primary)

                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
            }
            .navigationTitle("Your Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        UserSearchView(isPresentedModally: false)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .errorAlert(
                isPresented: $loggedInUserController.errorMessageShowing,
                message: loggedInUserController.errorMessageText
            )
        }
    }
}

struct AllChatsView_Previews: PreviewProvider {
    static var previews: some View {
        AllChatsView()
    }
}
