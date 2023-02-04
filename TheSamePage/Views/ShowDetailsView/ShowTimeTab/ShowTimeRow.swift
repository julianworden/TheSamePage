//
//  ShowTimeRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/13/22.
//

import SwiftUI

struct ShowTimeRow: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    @Binding var selectedShowTimeType: ShowTimeType?
    
    let showTimeType: ShowTimeType
    
    var body: some View {
        ZStack {
            HStack {
                ListRowElements(
                    title: viewModel.getShowTimeRowText(forShowTimeType: showTimeType),
                    iconName: showTimeType.rowIconName
                )
                
                Spacer()

                if viewModel.show.loggedInUserIsShowHost {
                    Menu {
                        if viewModel.timeForShowExists(showTimeType: showTimeType) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.removeShowTimeFromShow(showTimeType: showTimeType)
                                }
                            } label: {
                                Label("Delete Time", systemImage: "trash")
                            }
                        } else {
                            Button {
                                selectedShowTimeType = showTimeType
                            } label: {
                                Label("Add Time", systemImage: "plus")
                            }
                        }
                    } label: {
                        EllipsesMenuIcon()
                    }
                }
            }
        }
    }
}

struct ShowTimeRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeRow(viewModel: ShowDetailsViewModel(show: Show.example), selectedShowTimeType: .constant(nil), showTimeType: .doors)
    }
}
