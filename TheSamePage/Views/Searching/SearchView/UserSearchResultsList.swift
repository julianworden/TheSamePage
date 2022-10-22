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
        List {
            Section("Search Results...") {
                ForEach(viewModel.fetchedUsers, id: \.document) { result in
                    let user = result.document!
                    
                    if user.profileBelongsToLoggedInUser {
                        SearchResultRow(band: nil, user: user, show: nil)
                    } else {
                        NavigationLink {
                            OtherUserProfileView(user: user, bandMember: nil)
                        } label: {
                            SearchResultRow(band: nil, user: user, show: nil)
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
        .searchable(text: $viewModel.queryText, prompt: Text(viewModel.searchBarPrompt))
        .autocorrectionDisabled(true)
        .onChange(of: viewModel.queryText) { query in
            Task {
                do {
                    try await viewModel.fetchUsers(searchQuery: query)
                } catch {
                    print(error)
                }
            }
        }
    }
}


struct UserSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchResultsList(viewModel: SearchViewModel())
    }
}
