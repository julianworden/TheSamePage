//
//  ShowTimeRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/13/22.
//

import SwiftUI

struct ShowTimeRow: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    let showTimeType: ShowTimeType
    
    var body: some View {
        if let show = viewModel.show {
            ZStack {
                HStack {
                    ListRowElements(
                        title: viewModel.getShowTimeRowText(forShowTimeType: showTimeType),
                        iconName: showTimeType.rowIconName
                    )

                    Spacer()

                    if show.loggedInUserIsShowHost {
                        Menu {
                            Button {
                                viewModel.selectedShowTimeType = showTimeType
                            } label: {
                                Label("Edit Time", systemImage: "square.and.pencil")
                            }
                        } label: {
                            EllipsesMenuIcon()
                        }
                    }
                }
            }
        }
    }
}

struct ShowTimeRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeRow(viewModel: ShowDetailsViewModel(show: Show.example), showTimeType: .doors)
    }
}
