//
//  UserSearchResultsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import SwiftUI
import Typesense

struct UserSearchResultsList: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        List(viewModel.fetchedUsers, id: \.document) { result in
            let user = result.document!
            
            SearchResultRow(band: nil, user: user, show: nil)
        }
        .searchable(text: $viewModel.queryText, prompt: Text(viewModel.searchBarPrompt))
        .onChange(of: viewModel.queryText) { query in
            if !query.isEmpty {
                Task {
                    do {
                        try await viewModel.fetchUsers(searchQuery: query)
                    } catch {
                        print(error)
                    }
                }
            } else {
                viewModel.fetchedUsers = [SearchResultHit<User>]()
            }
        }
    }
}

struct UserSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchResultsList(viewModel: SearchViewModel())
    }
}
