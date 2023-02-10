//
//  ShowTimeList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

@MainActor
struct ShowTimeList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    var body: some View {
        if let show = viewModel.show {
            VStack(spacing: UiConstants.listRowSpacing) {
                ShowTimeRow(viewModel: viewModel, showTimeType: .loadIn)
                Divider()
                
                ShowTimeRow(viewModel: viewModel, showTimeType: .doors)
                Divider()
                
                ShowTimeRow(viewModel: viewModel, showTimeType: .musicStart)
                Divider()
                
                ShowTimeRow(viewModel: viewModel, showTimeType: .end)
                Divider()
            }
            .sheet(
                item: $viewModel.selectedShowTimeType,
                onDismiss: {
                    Task {
                        await viewModel.getLatestShowData()
                    }
                },
                content: { showTimeType in
                    AddEditShowTimeView(show: show, showTimeType: showTimeType)
                }
            )
        }
    }
}


struct ShowTimeList_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
