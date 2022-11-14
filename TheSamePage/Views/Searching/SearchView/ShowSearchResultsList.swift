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
        ScrollView {
            VStack(spacing: UiConstants.listRowSpacing) {
                ForEach(viewModel.fetchedShows, id: \.document) { result in
                    let show = result.document!
                    
                    NavigationLink {
                        ShowDetailsView(show: show)
                            // Necessary because ShowDetailsView assumes .navigationBarTitleDisplayMode(.large) otherwise
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        SearchResultRow(show: show)
                    }
                    .tint(.primary)
                }
                .searchable(text: $viewModel.queryText, prompt: Text(viewModel.searchBarPrompt))
                .autocorrectionDisabled(true)
            }
        }
        .onChange(of: viewModel.queryText) { query in
            Task {
                do {
                    try await viewModel.fetchShows(searchQuery: query)
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct ShowSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        ShowSearchResultsList(viewModel: SearchViewModel())
    }
}
