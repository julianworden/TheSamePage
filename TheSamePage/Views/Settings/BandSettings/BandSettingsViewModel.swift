//
//  BandSettingsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/13/22.
//

import Foundation

@MainActor
final class BandSettingsViewModel: ObservableObject {
    let band: Band
    
    init(band: Band) {
        self.band = band
    }
    
    func leaveBand(band: Band) {
        Task {
            do {
                let user = try await DatabaseService.shared.getLoggedInUser()
                try await DatabaseService.shared.removeUserFromBand(user: user, band: band)
            } catch {
                print(error)
                // TODO: Change State
            }
        }
    }
}
