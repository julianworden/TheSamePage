//
//  ShowSearchResultsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import SwiftUI
import Typesense

struct ShowSearchResultsList: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        List(viewModel.fetchedUsers, id: \.document) { result in
            let user = result.document!
            
            Text("\(user.firstName) \(user.lastName)")
        }
        .searchable(text: $viewModel.queryText, prompt: Text(viewModel.searchBarPrompt))
        .onChange(of: viewModel.queryText) { query in
            if !query.isEmpty {
                Task {
                    do {
                        try await viewModel.fetchShows(searchQuery: query)
                    } catch {
                        print(error)
                    }
                }
            } else {
                viewModel.fetchedShows = [SearchResultHit<Show>]()
            }
        }
    }
}

struct ShowSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        ShowSearchResultsList(viewModel: SearchViewModel())
    }
}
