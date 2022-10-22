//
//  BandSearchResultsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import SwiftUI
import Typesense

struct BandSearchResultsList: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        List {
            Section("Search Results...") {
                ForEach(viewModel.fetchedBands, id: \.document) { result in
                    let band = result.document!
                    
                    NavigationLink {
                        BandProfileRootView(band: band, showParticipant: nil)
                    } label: {
                        SearchResultRow(band: band, user: nil, show: nil)
                    }
                }
            }
        }
        .listStyle(.grouped)
        .searchable(text: $viewModel.queryText, prompt: Text(viewModel.searchBarPrompt))
        .autocorrectionDisabled(true)
        .onChange(of: viewModel.queryText) { query in
            if !query.isEmpty {
                Task {
                    do {
                        try await viewModel.fetchBands(searchQuery: query)
                    } catch {
                        print(error)
                    }
                }
            } else {
                viewModel.fetchedBands = [SearchResultHit<Band>]()
            }
        }
    }
}

struct BandSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        BandSearchResultsList(viewModel: SearchViewModel())
    }
}
