//
//  ShowCardViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import Foundation

class LargeListRowViewModel: ObservableObject {
    let showName: String
    let showVenue: String
    let showDescription: String
    let showDate: String
    let showHasFood: Bool
    let showHasBar: Bool
    let showIs21Plus: Bool
    
    init(show: Show?, joinedShow: JoinedShow?) {
        if let show {
            self.showName = show.name
            self.showVenue = show.venue
            self.showDescription = show.description ?? ""
            self.showDate = show.formattedDate
            self.showHasFood = show.hasFood
            self.showHasBar = show.hasBar
            self.showIs21Plus = show.is21Plus
        } else {
            self.showName = joinedShow!.name
            self.showVenue = joinedShow!.venue
            self.showDescription = joinedShow!.description ?? ""
            self.showDate = joinedShow!.date
            self.showHasFood = joinedShow!.hasFood
            self.showHasBar = joinedShow!.hasBar
            self.showIs21Plus = joinedShow!.is21Plus
        }
    }
}
