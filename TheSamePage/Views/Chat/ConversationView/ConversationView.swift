//
//  ConversationView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import SwiftUI

struct ConversationView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var appOpenedViaNotificationController: AppOpenedViaNotificationController
        
    @StateObject var viewModel: ConversationViewModel
    
    init(chatId: String? = nil, show: Show? = nil, userId: String? = nil, chatParticipantUids: [String] = [], isPresentedModally: Bool = false) {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(chatId: chatId, show: show, userId: userId, chatParticipantUids: chatParticipantUids, isPresentedModally: isPresentedModally))
    }

    var body: some View {
        ZStack {
            BackgroundColor()

            if viewModel.viewState == .dataLoading {
                ProgressView()
            } else {
                ConversationViewMessagesList(viewModel: viewModel)
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isPresentedModally {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ChatInfoView(show: viewModel.show, chatParticipantUids: viewModel.chatParticipantUids)
                } label: {
                    Image(systemName: "info.circle")
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
        .onDisappear {
            viewModel.removeChatListener()
            Task {
                await viewModel.removeChatViewer()
            }
        }
        .onChange(of: viewModel.messageText) { messageText in
            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.sendButtonIsDisabled = false
            } else {
                viewModel.sendButtonIsDisabled = true
            }
        }
        .onForeground {
            Task {
                await viewModel.addChatViewer()
            }
        }
        .onBackground {
            Task {
                await viewModel.removeChatViewer()
            }
        }
        .onChange(of: appOpenedViaNotificationController.presentViewFromNotification) { presentViewFromNotification in
            if !presentViewFromNotification {
                Task {
                    await viewModel.removeChatViewer()
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
