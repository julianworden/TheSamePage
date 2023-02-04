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

    @State private var selectedShowTimeType: ShowTimeType?
    
    var body: some View {
        let show = viewModel.show
        
        VStack(spacing: UiConstants.listRowSpacing) {
            ShowTimeRow(viewModel: viewModel, selectedShowTimeType: $selectedShowTimeType, showTimeType: .loadIn)
            Divider()

            ShowTimeRow(viewModel: viewModel, selectedShowTimeType: $selectedShowTimeType, showTimeType: .doors)
            Divider()

            ShowTimeRow(viewModel: viewModel, selectedShowTimeType: $selectedShowTimeType, showTimeType: .musicStart)
            Divider()

            ShowTimeRow(viewModel: viewModel, selectedShowTimeType: $selectedShowTimeType, showTimeType: .end)
            Divider()
        }
        .sheet(
            item: $selectedShowTimeType,
            onDismiss: {
                Task {
                    await viewModel.getLatestShowData()
                }
            },
            content: { showTimeType in
                NavigationStack {
                    switch showTimeType {
                    case .loadIn:
                        AddShowTimeView(show: show, showTimeType: showTimeType)
                    case .musicStart:
                        AddShowTimeView(show: show, showTimeType: showTimeType)
                    case .end:
                        AddShowTimeView(show: show, showTimeType: showTimeType)
                    case .doors:
                        AddShowTimeView(show: show, showTimeType: showTimeType)
                    }
                }
            }
        )
    }
}

    
struct ShowTimeList_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
