//
//  ChatInfoView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/7/22.
//

import SwiftUI

struct ChatInfoView: View {
    @StateObject var viewModel: ChatInfoViewModel
    
    init(show: Show?, chatParticipantUids: [String]) {
        _viewModel = StateObject(wrappedValue: ChatInfoViewModel(show: show, chatParticipantUids: chatParticipantUids))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()

            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()

            case .dataLoaded:
                List {
                    if viewModel.show != nil,
                       let showHost = viewModel.showHost {
                        Section("Show Host") {
                            NavigationLink {
                                OtherUserProfileView(user: showHost)
                            } label: {
                                Text(showHost.fullName)
                            }
                        }
                    }

                    if !viewModel.chatParticipantUids.isEmpty {
                        Section("Show Partipants") {
                            ForEach(viewModel.chatParticipants) { chatParticipant in
                                NavigationLink {
                                    OtherUserProfileView(user: chatParticipant)
                                } label: {
                                    Text(chatParticipant.fullName)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Chat Details")
                .navigationBarTitleDisplayMode(.inline)

            default:
                ErrorMessage(message: ErrorMessageConstants.invalidViewState)
            }
        }
        .task {
            await viewModel.fetchChatParticipantsAsUsers()
            if viewModel.show != nil {
                await viewModel.fetchShowHostAsUser()
            }
        }
    }
}

struct ChatInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChatInfoView(show: Show.example, chatParticipantUids: [])
    }
}
