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
        Group {
            if !viewModel.bands.isEmpty {
                OtherUserShowsList(viewModel: viewModel)
            } else {
                NoDataFoundMessage(message: "This user hasn't been involved in any shows on The Same Page.")
            }
        }
        .padding(.horizontal)
    }
}

struct OtherUserShowsTab_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserShowsTab(viewModel: OtherUserProfileViewModel(user: nil))
    }
}
