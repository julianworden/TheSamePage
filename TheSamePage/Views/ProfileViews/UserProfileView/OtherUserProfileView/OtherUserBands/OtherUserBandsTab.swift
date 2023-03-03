//
//  OtherUserBandsTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 3/3/23.
//

import SwiftUI

struct OtherUserBandsTab: View {
    @ObservedObject var viewModel: OtherUserProfileViewModel

    var body: some View {
        if !viewModel.bands.isEmpty {
            OtherUserBandList(viewModel: viewModel)
        } else {
            NoDataFoundMessage(message: "This user is not affiliated with any bands on The Same Page.")
        }
    }
}

struct OtherUserBandsTab_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserBandsTab(viewModel: OtherUserProfileViewModel(user: nil))
    }
}
