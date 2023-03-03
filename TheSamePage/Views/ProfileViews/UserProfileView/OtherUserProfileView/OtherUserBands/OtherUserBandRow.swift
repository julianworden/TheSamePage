//
//  OtherUserBandRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/17/22.
//

import SwiftUI

struct OtherUserBandRow: View {
    @ObservedObject var viewModel: OtherUserProfileViewModel
    
    let index: Int

    var body: some View {
        if viewModel.bands.indices.contains(index) {
            let band = viewModel.bands[index]

            ListRowElements(
                title: band.name,
                subtitle: "\(band.city), \(band.state)",
                iconName: "person.3",
                iconIsSfSymbol: true
            )
        }
    }
}

struct OtherUserBandRow_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserBandRow(viewModel: OtherUserProfileViewModel(user: User.example, bandMember: nil), index: 0)
    }
}
