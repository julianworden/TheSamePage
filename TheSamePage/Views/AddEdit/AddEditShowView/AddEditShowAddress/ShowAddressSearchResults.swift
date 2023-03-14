//
//  ShowAddressSearchResultsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/17/22.
//

import CoreLocation
import SwiftUI

struct ShowAddressSearchResults: View {
    @ObservedObject var viewModel: AddEditShowAddressViewModel
    
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Necessary for overlay to cover entire view
            Rectangle()
                .foregroundColor(.clear)
                .ignoresSafeArea()
            
            if let showAddress = viewModel.showAddress {
                VStack {
                    Text("Selected Address")
                        .font(.title2.bold())
                    
                    Text(showAddress)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
            }
        }
        .onChange(of: viewModel.queryText) { searchText in
            Task {
                await viewModel.search(withText: searchText)
            }
        }
        .onChange(of: isSearching) { isSearching in
            viewModel.isSearchingChanged(to: isSearching)
        }
        .overlay {
            AddressSearchList(viewModel: viewModel)
        }
    }
}

struct ShowAddressSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowAddressSearchResults(viewModel: AddEditShowAddressViewModel(showToEdit: Show.example))
    }
}
