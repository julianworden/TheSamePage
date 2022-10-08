//
//  ShowLineupRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import Foundation

class ShowLineupRowViewModel: ObservableObject {
    let showParticipantName: String
    let rowIndex: Int
    let lineupCount: Int
    
    init(showParticipant: ShowParticipant, rowIndex: Int, lineupCount: Int) {
        self.showParticipantName = showParticipant.name
        self.rowIndex = rowIndex
        self.lineupCount = lineupCount
    }
}
