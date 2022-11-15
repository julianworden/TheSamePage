//
//  ShowSettingsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/14/22.
//

import Foundation

class ShowSettingsViewModel: ObservableObject {
    let show: Show
    
    init(show: Show) {
        self.show = show
    }
    
    func cancelShow() {
        Task {
            do {
                try await DatabaseService.shared.cancelShow(show: show)
            } catch {
                // TODO: Change state
            }
        }
    }
}
