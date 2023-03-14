//
//  AddLinkViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import Foundation
// TODO: WRITE TESTS FOR THIS AND ADD VIEWSTATE STUFF
@MainActor
final class AddEditLinkViewModel: ObservableObject {
    @Published var linkPlatform = LinkPlatform.instagram
    @Published var enteredUrlAsString = ""

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    @Published var buttonsAreDisabled = false
    @Published var dismissView = false

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                dismissView = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }
    
    var linkToEdit: PlatformLink?
    let band: Band

    init(linkToEdit: PlatformLink?, band: Band) {
        self.band = band
        
        if let linkToEdit {
            self.linkPlatform = linkToEdit.platformNameAsPlatformLinkObject
            self.enteredUrlAsString = linkToEdit.url
            self.linkToEdit = linkToEdit
        }
    }
    
    func uploadBandLink() throws {
        viewState = .performingWork

        if URL(string: enteredUrlAsString) != nil {
            let newLink = PlatformLink(platformName: linkPlatform.rawValue, url: enteredUrlAsString)
            try DatabaseService.shared.uploadBandLink(withLink: newLink, forBand: band)
            viewState = .workCompleted
        } else {
            viewState = .error(message: "It looks like you entered an invalid URL. Please try again.")
        }
    }
}
