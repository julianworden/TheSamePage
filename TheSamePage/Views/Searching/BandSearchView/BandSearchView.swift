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
        List(viewModel.fetchedResults) { result in
            let band = result.searchable as! Band
            
            Text(band.name)
        }
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search) {
            Task {
                do {
                    try await viewModel.getBands()
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
