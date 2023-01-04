//
//  BandSearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import SwiftUI

struct BandSearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundColor()
            
            BandSearchResultsList(viewModel: viewModel)
                .searchable(text: $viewModel.queryText, prompt: Text("Search by band name"))
                .autocorrectionDisabled(true)
                .padding(.horizontal)
        }
    }
}

struct BandSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandSearchView(viewModel: SearchViewModel())
        }
    }
}
