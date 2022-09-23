//
//  NotificationsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import Foundation

class NotificationsViewModel: ObservableObject {
    @Published var fetchedNotifications = [BandInvite]()
    
    @MainActor
    func getNotifications() async throws {
        fetchedNotifications = try await DatabaseService.shared.getNotifications()
    }
}
