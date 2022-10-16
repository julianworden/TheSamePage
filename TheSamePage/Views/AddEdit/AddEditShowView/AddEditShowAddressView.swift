//
//  AddEditShowAddressView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/15/22.
//

import SwiftUI

struct AddEditShowAddressView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: AddEditShowViewModel
    
    @Binding var showAddress: String?
    
    var body: some View {
        List(viewModel.addressSearchResults, id: \.self) { placemark in
            if let address = placemark.formattedAddress {
                Button {
                    // Done this way to avoid a "Publishing changes from view updates is not allowed" runtime error"
                    showAddress = address
                    viewModel.setShowLocationInfo(withPlacemark: placemark)
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        if let placeName = placemark.name {
                            Text(placeName)
                                .bold()
                        }
                        Text(address)
                    }
                }
                .tint(.black)
            }
        }
        .searchable(text: $viewModel.queryText, prompt: Text("Search for venue name or address"))
        .autocorrectionDisabled(true)
        .onChange(of: viewModel.queryText) { searchText in
            if !searchText.isEmpty {
                Task {
                    do {
                        try await viewModel.search(withText: searchText)
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .onDisappear {
            viewModel.addressSearch?.cancel()
            viewModel.queryText = ""
        }
    }
}

struct AddEditShowAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowAddressView(viewModel: AddEditShowViewModel(viewTitleText: "Edit Show", showToEdit: nil), showAddress: .constant(""))
    }
}
