//
//  ShowDetailsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import Foundation

class ShowDetailsViewModel: ObservableObject {
    let show: Show
    let showName: String
    let showDescription: String
    let showDate: String
    let showGenre: String
    let showHost: String
    let showVenue: String
    let showImageUrl: String?
    let showMaxNumberOfBands: Int
    @Published var showLineup = [ShowParticipant]()
    
    var showLineupSummary: String {
        let slotsRemainingCount = showMaxNumberOfBands - showLineup.count
        
        if slotsRemainingCount == 1 {
            return "\(slotsRemainingCount) slot remaining"
        } else {
            return "\(slotsRemainingCount) slots remaining"
        }
    }
    
    init(show: Show) {
        self.show = show
        self.showName = show.name
        self.showDescription = show.description ?? ""
        self.showDate = show.formattedDate
        self.showGenre = show.genre
        self.showHost = show.host
        self.showVenue = show.venue
        self.showImageUrl = show.imageUrl
        self.showMaxNumberOfBands = show.maxNumberOfBands
        
        Task {
            do {
                try await getShowLineup()
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor
    func getShowLineup() async throws {
        showLineup = try await DatabaseService.shared.getShowLineup(forShow: show)
    }
}
