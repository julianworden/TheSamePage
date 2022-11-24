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
        let show = viewModel.show
        
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
                        ShowBacklineTab(viewModel: viewModel)
                    case .times:
                        ShowTimeTab(viewModel: viewModel)
                    case .location:
                        ShowLocationTab(show: show, viewModel: viewModel)
                    case .details:
                        ShowDetailsTab(viewModel: viewModel)
                    }
                }
                
            case .error(let message):
                ErrorMessage(
                    message: "Failed to fetch details for this show.",
                    systemErrorText: message
                )
                
            default:
                ErrorMessage(message: ErrorMessageConstants.unknownViewState)
            }
        }
        .navigationTitle("Show Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                if show.loggedInUserIsShowHost {
                    NavigationLink {
                        ShowSettingsView(show: show)
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .onAppear {
            viewModel.addShowListener()
        }
        .onDisappear {
            viewModel.removeShowListener()
        }
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
