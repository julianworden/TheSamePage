//
//  BandMemberRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import Foundation

final class BandMemberCardViewModel: ObservableObject {
    @Published var memberRole = ""
    @Published var memberName = ""
    
    let memberUid: String
    
    init(bandMember: BandMember) {
        self.memberRole = bandMember.role
        self.memberName = bandMember.name
        self.memberUid = bandMember.uid
    }
}
