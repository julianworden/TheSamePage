//
//  ShowDetailsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import SwiftUI

struct ShowDetailsView: View {
    @StateObject var viewModel: ShowDetailsViewModel
        
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowDetailsViewModel(show: show))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            switch viewModel.state {
            case .dataLoading:
                ProgressView()
            case .dataLoaded:
                ScrollView {
                    ShowDetailsHeader(viewModel: viewModel)
                    
                    Picker("Select View", selection: $viewModel.selectedTab) {
                        ForEach(SelectedShowDetailsTab.allCases) { tabName in
                            Text(tabName.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    switch viewModel.selectedTab {
                    case .lineup:
                        ShowLineupTab(viewModel: viewModel)
                    case .backline:
                        ShowBacklineTab(show: viewModel.show)
                    case .times:
                        ShowTimeTab(show: viewModel.show)
                    case .location:
                        ShowLocationTab(show: viewModel.show)
                    case .details:
                        ShowDetailsTab(viewModel: viewModel)
                    }
                }
            case .dataNotFound:
                ErrorMessage(
                    message: "Failed to fetch details for this show.",
                    errorText: "Please check your internet connection and restart the app."
                )
            case .error(let message):
                ErrorMessage(
                    message: "Failed to fetch details for this show.",
                    errorText: message
                )
            }
        }
        .navigationTitle("Show Details")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

// TODO: Figure out why this preview crashes
struct ShowDetailsRootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowDetailsView(show: Show.example)
        }
    }
}
