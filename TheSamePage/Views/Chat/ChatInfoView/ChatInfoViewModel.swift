//
//  ChatInfoViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/7/22.
//

import Foundation

@MainActor
final class ChatInfoViewModel: ObservableObject {
    @Published var chatParticipants = [User]()
    let chatParticipantUids: [String]

    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                if viewState != .dataLoaded {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }

    var show: Show?

    init(show: Show?, chatParticipantUids: [String]) {
        self.show = show
        self.chatParticipantUids = chatParticipantUids

        Task {
            await fetchChatParticipantsAsUsers()
            if show != nil {
                await fetchShowHostAsUser()
            }
        }
    }

    func getChatParticipantRowSubtitleText(for chatParticipant: User) -> String {
        if let show,
           chatParticipant.id == show.hostUid {
            return "Show Host"
        } else {
            return ""
        }
    }

    func fetchChatParticipantsAsUsers() async {
        guard !chatParticipantUids.isEmpty else { return }

        do {
            var chatParticipants = [User]()

            for uid in chatParticipantUids {
                let participantAsUser = try await DatabaseService.shared.getUser(withUid: uid)
                if !self.chatParticipants.contains(participantAsUser) {
                    chatParticipants.append(participantAsUser)
                }
            }

            self.chatParticipants = chatParticipants

            if show == nil {
                viewState = .dataLoaded
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func fetchShowHostAsUser() async {
        guard let show else {
            viewState = .error(message: "Failed to fetch chat info. Please restart The Same Page and try again.")
            return
        }

        guard !chatParticipants.contains(where: { user in
            user.id == show.hostUid
        }) else { return }

        do {
            let showHost = try await DatabaseService.shared.getUser(withUid: show.hostUid)
            self.chatParticipants.append(showHost)

            viewState = .dataLoaded
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
