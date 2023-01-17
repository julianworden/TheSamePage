//
//  ShowTimeTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

struct ShowTimeTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    @State private var selectedShowTimeType: ShowTimeType?
    @State private var showTimeToEdit: Date?
    
    var body: some View {
        let show = viewModel.show
        
        VStack {
            if show.loggedInUserIsShowHost {
                AddShowTimeButtons(viewModel: viewModel, selectedShowTimeType: $selectedShowTimeType)
            }
            
            if show.hasTime {
                ShowTimeList(viewModel: viewModel)
            } else {
                Text(viewModel.noShowTimesMessage)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
        .sheet(
            item: $selectedShowTimeType,
            onDismiss: {
                Task {
                    await viewModel.getLatestShowData()
                }
            },
            content: { showTimeType in
                NavigationView {
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

struct ShowTimeTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
