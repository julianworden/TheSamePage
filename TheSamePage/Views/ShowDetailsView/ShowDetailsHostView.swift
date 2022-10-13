//
//  ShowDetailsHostView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import SwiftUI

struct ShowDetailsHostView: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        ScrollView {
            ShowDetailsHeader(viewModel: viewModel)
            
            Text(viewModel.showDescription)
                .padding(.top, 3)
                .padding(.horizontal)
            
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
                ShowBacklineTab()
            case .times:
                ShowTimeTab(show: viewModel.show)
            case .location:
                ShowLocationTab()
            case .details:
                ShowDetailsTab(viewModel: viewModel)
            }
        }
    }
}

struct ShowDetailsHostView_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsHostView(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
