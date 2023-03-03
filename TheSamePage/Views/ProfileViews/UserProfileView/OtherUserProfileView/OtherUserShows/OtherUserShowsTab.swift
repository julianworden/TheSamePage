//
//  OtherUserShowsTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 3/3/23.
//

import SwiftUI

struct OtherUserShowsTab: View {
    @ObservedObject var viewModel: OtherUserProfileViewModel

    var body: some View {
        if !viewModel.bands.isEmpty {
            OtherUserShowsList(viewModel: viewModel)
        } else {
            NoDataFoundMessage(message: "This user is not affiliated with any bands on The Same Page.")
        }
    }
}

struct OtherUserShowsTab_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserShowsTab(viewModel: OtherUserProfileViewModel(user: nil))
    }
}
