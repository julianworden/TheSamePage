//
//  OtherUserShowsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 3/3/23.
//

import SwiftUI

struct OtherUserShowsList: View {
    @ObservedObject var viewModel: OtherUserProfileViewModel

    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(viewModel.shows.enumerated()), id: \.element) { index, show in
                NavigationLink {
                    ShowDetailsView(show: show)
                } label: {
                    OtherUserShowRow(viewModel: viewModel, index: index)
                }
                .tint(.primary)

                Divider()
            }
        }
        .padding(.top, 5)
    }
}

struct OtherUserShowsList_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserShowsList(viewModel: OtherUserProfileViewModel(user: nil))
    }
}
