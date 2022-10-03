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
            List(viewModel.fetchedResults) { result in
                Text(result.searchable.name)
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Picker("", selection: $viewModel.searchType) {
                        ForEach(SearchType.allCases) { searchType in
                            Text(searchType.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: Text(viewModel.searchBarPrompt))
            .onSubmit(of: .search) {
                Task {
                    do {
                        try await viewModel.performSearch()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
