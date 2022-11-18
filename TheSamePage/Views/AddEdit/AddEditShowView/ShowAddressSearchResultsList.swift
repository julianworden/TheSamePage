//
//  ShowAddressSearchResultsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/17/22.
//

import CoreLocation
import SwiftUI

struct ShowAddressSearchResultsList: View {
    @ObservedObject var viewModel: AddEditShowViewModel
    
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
            if isSearching && !viewModel.addressSearchResults.isEmpty {
                List(viewModel.addressSearchResults, id: \.self) { placemark in
                    if let address = placemark.formattedAddress {
                        Button {
                            viewModel.setShowLocationInfo(with: placemark)
                        } label: {
                            VStack(alignment: .leading) {
                                if let placeName = placemark.name {
                                    Text(placeName)
                                        .bold()
                                }
                                Text(address)
                            }
                        }
                        .tint(.primary)
                    }
                }
                .onChange(of: viewModel.showAddressSelected) { _ in
                    dismissSearch()
                }
            } else if isSearching && viewModel.addressSearchResults.isEmpty {
                ZStack {
                    Color(uiColor: .systemGroupedBackground)
                        .ignoresSafeArea()

                    VStack {
                        Text("No results found.")
                            .italic()
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ShowAddressSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowAddressSearchResultsList(viewModel: AddEditShowViewModel())
    }
}
