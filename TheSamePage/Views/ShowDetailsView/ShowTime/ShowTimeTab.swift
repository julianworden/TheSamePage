//
//  ShowTimeTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

struct ShowTimeTab: View {
    @StateObject var viewModel: ShowTimeTabViewModel
    
    @State private var selectedShowTimeType: ShowTimeType?
    @State private var showTimeToEdit: Date?
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowTimeTabViewModel(show: show))
    }
    
    var body: some View {
        VStack {
            if viewModel.show.loggedInUserIsShowHost {
                AddShowTimeButtons(viewModel: viewModel, selectedShowTimeType: $selectedShowTimeType)
            }
            
            if viewModel.showHasTimes {
                ShowTimeList(viewModel: viewModel)
            } else {
                Text(viewModel.noShowTimesMessage)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
        }
        .padding(.horizontal)
        .onAppear {
            do {
                try viewModel.addShowTimesListener()
            } catch {
                print(error)
            }
        }
        .onDisappear {
            viewModel.removeShowTimesListener()
        }
        .sheet(item: $selectedShowTimeType) { showTimeType in
            NavigationView {
                switch showTimeType {
                case .loadIn:
                    AddShowTimeView(show: viewModel.show, showTimeType: showTimeType)
                case .musicStart:
                    AddShowTimeView(show: viewModel.show, showTimeType: showTimeType)
                case .end:
                    AddShowTimeView(show: viewModel.show, showTimeType: showTimeType)
                case .doors:
                    AddShowTimeView(show: viewModel.show, showTimeType: showTimeType)
                }
            }
        }
    }
}

struct ShowTimeTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeTab(show: Show.example)
    }
}
