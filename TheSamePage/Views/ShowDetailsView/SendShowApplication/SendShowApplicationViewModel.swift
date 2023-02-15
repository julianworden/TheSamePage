//
//  SendShowApplicationViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/8/23.
//

import Foundation

@MainActor
final class SendShowApplicationViewModel: ObservableObject {
    @Published var adminBands = [Band]()
    @Published var selectedBand: Band?

    @Published var buttonsAreDisabled = false
    @Published var asyncOperationCompletedSuccessfully = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    let show: Show

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                asyncOperationCompletedSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                if viewState != .dataNotFound && viewState != .dataLoaded {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }

    init(show: Show) {
        self.show = show
    }

    func getLoggedInUserAdminBands() async {
        do {
            adminBands = try await DatabaseService.shared.getAdminBands(withUid: AuthController.getLoggedInUid())

            if !adminBands.isEmpty {
                selectedBand = adminBands.first!
                viewState = .dataLoaded
            } else {
                viewState = .dataNotFound
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    @discardableResult func sendShowApplication() async -> String {
        do {
            guard let selectedBand else {
                viewState = .error(message: "Failed to send show application, please restart The Same Page and try again.")
                return ""
            }

            viewState = .performingWork

            let recipientFcmToken = try await DatabaseService.shared.getFcmToken(forUserWithUid: show.hostUid)
            let senderFcmToken = try await AuthController.getLoggedInFcmToken()

            let showApplication = ShowApplication(
                id: "",
                recipientFcmToken: recipientFcmToken,
                senderFcmToken: senderFcmToken,
                sentTimestamp: Date.now.timeIntervalSince1970,
                bandName: selectedBand.name,
                message: "\(selectedBand.name) wants to play \(show.name).",
                recipientUid: show.hostUid,
                showId: show.id,
                showName: show.name,
                bandId: selectedBand.id
            )

            let createdShowApplicationId = try await DatabaseService.shared.sendShowApplication(application: showApplication)
            viewState = .workCompleted
            return createdShowApplicationId
        } catch {
            viewState = .error(message: error.localizedDescription)
            return ""
        }
    }
}
