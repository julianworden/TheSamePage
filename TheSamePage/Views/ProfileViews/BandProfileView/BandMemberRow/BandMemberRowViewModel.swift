//
//  BandMemberRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import Foundation

final class BandMemberRowViewModel: ObservableObject {
    let memberRole: String
    let memberName: String
    let iconName: String
    let index: Int
    let membersCount: Int
    let memberUid: String
    let bandMemberIsLoggedInUser: Bool
    
    init(bandMember: BandMember, index: Int, membersCount: Int, bandMemberIsLoggedInUser: Bool) {
        self.memberRole = bandMember.role
        self.memberName = bandMember.fullName
        self.iconName = bandMember.role.lowercased()
        self.memberUid = bandMember.uid
        self.index = index
        self.membersCount = membersCount
        self.bandMemberIsLoggedInUser = bandMemberIsLoggedInUser
    }
}
