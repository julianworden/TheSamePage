//
//  SearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/26/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    Picker("", selection: $viewModel.searchType) {
                        ForEach(SearchType.allCases) { searchType in
                            Text(searchType.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if viewModel.searchType == .user{
                        UserSearchResultsList(viewModel: viewModel)
                    }
                    
                    if viewModel.searchType == .band {
                        BandSearchResultsList(viewModel: viewModel)
                    }
                    
                    if viewModel.searchType == .show {
                        ShowSearchResultsList(viewModel: viewModel)
                    }
                }
                .navigationTitle("Search")
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
