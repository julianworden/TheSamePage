//
//  SearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/26/22.
//

import SwiftUI

/// Shown when the Search button in the TabView is selected
struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                BackgroundColor()
                
                VStack {
                    Picker("", selection: $viewModel.searchType) {
                        ForEach(SearchType.allCases) { searchType in
                            Text(searchType.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch viewModel.searchType {
                    case .user:
                        UserSearchResultsList(viewModel: viewModel)
                            .searchable(text: $viewModel.queryText, prompt: Text(viewModel.searchBarPrompt))
                            .autocorrectionDisabled(true)
                        
                    case .band:
                        BandSearchResultsList(viewModel: viewModel)
                            .searchable(text: $viewModel.queryText, prompt: Text(viewModel.searchBarPrompt))
                            .autocorrectionDisabled(true)
                        
                    case .show:
                        ShowSearchResultsList(viewModel: viewModel)
                            .searchable(text: $viewModel.queryText, prompt: Text(viewModel.searchBarPrompt))
                            .autocorrectionDisabled(true)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Search")
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText
            )
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
