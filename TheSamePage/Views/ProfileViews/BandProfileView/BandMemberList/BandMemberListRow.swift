//
//  BandMemberListRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct BandMemberListRow: View {
    let title: String
    let subtitle: String
    let iconName: String
    let displayChevron: Bool
    let index: Int
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BandMemberListRow_Previews: PreviewProvider {
    static var previews: some View {
        BandMemberListRow(title: "Julian Worden", subtitle: "Vocals", iconName: "vocals", displayChevron: true, index: 0)
    }
}
