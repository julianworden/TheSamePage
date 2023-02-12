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
    var showHost: User?

    init(show: Show?, chatParticipantUids: [String]) {
        self.show = show
        self.chatParticipantUids = chatParticipantUids
    }

    func fetchChatParticipantsAsUsers() async {
        guard !chatParticipantUids.isEmpty else { return }

        do {
            var chatParticipants = [User]()

            for uid in chatParticipantUids {
                chatParticipants.append(try await DatabaseService.shared.getUser(withUid: uid))
            }

            self.chatParticipants = chatParticipants
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func fetchShowHostAsUser() async {
        guard let show else {
            viewState = .error(message: "Failed to fetch chat info. Please restart The Same Page and try again.")
            return
        }

        do {
            showHost = try await DatabaseService.shared.getUser(withUid: show.hostUid)
            viewState = .dataLoaded
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
