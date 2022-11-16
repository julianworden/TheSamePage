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
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
        }
        .padding(.horizontal)
        .sheet(
            item: $selectedShowTimeType,
            // This onDismiss is necessary for the show's updated times to get reflect on the UI.
            // If it's not here, the show gets updated properly, but the UI doesn't reflect it.
            onDismiss: { viewModel.addShowListener() },
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
