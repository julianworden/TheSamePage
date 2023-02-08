//
//  AddEditShowTimeViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import Foundation

@MainActor
final class AddEditShowTimeViewModel: ObservableObject {
    @Published var showTime = Date.now

    @Published var buttonsAreDisabled = false
    @Published var asyncOperationCompleted = false
    @Published var deleteSetTimeConfirmationAlertIsShowing = false

    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""
    
    let show: Show
    var showTimeType: ShowTimeType

    var showTimeIsBeingEdited: Bool {
        switch showTimeType {
        case .loadIn:
            return show.loadInTime != nil ? true : false
        case .musicStart:
            return show.musicStartTime != nil ? true : false
        case .end:
            return show.endTime != nil ? true : false
        case .doors:
            return show.doorsTime != nil ? true : false
        }
    }

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                asyncOperationCompleted = true
            case .error(let message):
                errorAlertIsShowing = true
                errorAlertText = message
                buttonsAreDisabled = false
            default:
                errorAlertIsShowing = true
                errorAlertText = ErrorMessageConstants.invalidViewState
            }
        }
    }
    
    init(show: Show, showTimeType: ShowTimeType) {
        self.show = show
        self.showTimeType = showTimeType
        setShowTimeToEdit()
    }

    /// Called when AddEditShowTimeView is used for editing a show time.
    func setShowTimeToEdit() {
        switch showTimeType {
        case .loadIn:
            showTime = show.loadInTime?.unixDateAsDate ?? show.date.unixDateAsDate
        case .musicStart:
            showTime = show.musicStartTime?.unixDateAsDate ?? show.date.unixDateAsDate
        case .end:
            showTime = show.endTime?.unixDateAsDate ?? show.date.unixDateAsDate
        case .doors:
            showTime = show.doorsTime?.unixDateAsDate ?? show.date.unixDateAsDate
        }
    }
    
    func addShowTime() async {
        do {
            viewState = .performingWork
            try await DatabaseService.shared.addTimeToShow(
                addTime: showTime,
                ofType: showTimeType,
                forShow: show
            )
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func deleteShowTime() async {
        do {
            viewState = .performingWork
            try await DatabaseService.shared.deleteTimeFromShow(delete: showTimeType, fromShow: show)
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
