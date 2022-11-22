//
//  AddressSearchList.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/21/22.
//

import SwiftUI

struct AddressSearchList: View {
    @ObservedObject var viewModel: AddEditShowAddressViewModel
    
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    
    var body: some View {
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

struct AddressSearchList_Previews: PreviewProvider {
    static var previews: some View {
        AddressSearchList(viewModel: AddEditShowAddressViewModel(showToEdit: Show.example))
    }
}
