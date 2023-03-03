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
                    if !viewModel.chatParticipantUids.isEmpty {
                        Section("Participants") {
                            ForEach(viewModel.chatParticipants) { chatParticipant in
                                if chatParticipant.isLoggedInUser {
                                    ListRowElements(
                                        title: "You",
                                        subtitle: viewModel.chatParticipantRowSubtitleText(for: chatParticipant),
                                        iconName: "person",
                                        iconIsSfSymbol: true
                                    )
                                } else {
                                    NavigationLink {
                                        OtherUserProfileView(user: chatParticipant)
                                    } label: {
                                        ListRowElements(
                                            title: chatParticipant.name,
                                            subtitle: viewModel.chatParticipantRowSubtitleText(for: chatParticipant),
                                            iconName: "person",
                                            iconIsSfSymbol: true
                                        )
                                    }
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
    }
}

struct ChatInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChatInfoView(show: Show.example, chatParticipantUids: [])
    }
}
