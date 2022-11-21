//
//  ShowSettingsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/14/22.
//

import Foundation

@MainActor
final class ShowSettingsViewModel: ObservableObject {
    @Published var addEditShowSheetIsShowing = false
    @Published var cancelShowAlertIsShowing = false
    
    @Published var errorAlertIsShowing = false
    var errorAlertMessage = ""
    
    let show: Show
    
    init(show: Show) {
        self.show = show
    }
    
    func cancelShow() async {
        do {
            try await DatabaseService.shared.cancelShow(show: show)
        } catch {
            errorAlertMessage = error.localizedDescription
            errorAlertIsShowing = true
        }
    }
}
