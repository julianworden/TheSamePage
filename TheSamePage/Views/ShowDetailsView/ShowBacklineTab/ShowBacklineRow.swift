//
//  ShowBacklineRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import SwiftUI

struct ShowBacklineRow: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    let index: Int
    
    var body: some View {
        if viewModel.showBackline.indices.contains(index) {
            let anyBackline = viewModel.showBackline[index]

            HStack {
                ListRowElements(
                    title: anyBackline.backline.name,
                    subtitle: anyBackline.backline.notes,
                    iconName: anyBackline.iconName
                )

                Spacer()

                if anyBackline.loggedInUserIsBackliner || viewModel.show.loggedInUserIsShowHost {
                    ShowBacklineRowMenuButton(viewModel: viewModel, anyBackline: anyBackline)
                }
            }
        }
    }
}

//struct ShowBacklineRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ShowBacklineRow(
//            viewModel: ShowDetailsViewModel(show: Show.example),
//            anyBackline: AnyBackline(id: <#T##String#>, backline: BacklineItem(backlinerUid: "asdfasdf", backlinerFullName: "Julian Worden", type: <#T##String#>, name: <#T##String#>))
//            title: "Drums",
//            subtitle: "Kick, snare, toms",
//            iconName: "drums"
//        )
//    }
//}
