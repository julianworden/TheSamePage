//
//  BandMemberRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import Foundation

final class BandMemberRowViewModel: ObservableObject {
    @Published var memberRole = ""
    @Published var memberName = ""
    
    let index: Int
    let membersCount: Int
    let memberUid: String
    let bandMemberIsLoggedInUser: Bool
    
    init(bandMember: BandMember, index: Int, membersCount: Int, bandMemberIsLoggedInUser: Bool) {
        self.memberRole = bandMember.role
        self.memberName = bandMember.name
        self.memberUid = bandMember.uid
        self.index = index
        self.membersCount = membersCount
        self.bandMemberIsLoggedInUser = bandMemberIsLoggedInUser
    }
}
