//
//  BandSearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import SwiftUI

struct BandSearchView: View {
    @StateObject var viewModel = BandSearchViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.fetchedBands, id: \.document) { result in
                let band = result.document!
                
                NavigationLink {
                    BandProfileView(band: band)
                } label: {
                    SearchResultRow(band: band)
                }
            }
        }
        .searchable(text: $viewModel.queryText)
        .autocorrectionDisabled(true)
        .onChange(of: viewModel.queryText) { query in
            Task {
                do {
                    try await viewModel.fetchBands(searchQuery: query)
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct BandSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandSearchView()
        }
    }
}
