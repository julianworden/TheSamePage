//
//  ShowBacklineList.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/4/23.
//

import SwiftUI

struct ShowBacklineList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    var body: some View {
        ForEach(Array(viewModel.showBackline.enumerated()), id: \.offset) { index, _ in
            ShowBacklineRow(
                viewModel: viewModel,
                index: index
            )

            Divider()
        }
    }
}

struct ShowBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        ShowBacklineList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
