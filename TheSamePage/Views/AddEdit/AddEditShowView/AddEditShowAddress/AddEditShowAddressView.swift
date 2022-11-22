//
//  AddEditShowAddressView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/15/22.
//

import MapKit
import SwiftUI

struct AddEditShowAddressView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddEditShowAddressViewModel
    
    init(showToEdit: Show?) {
        _viewModel = StateObject(wrappedValue: AddEditShowAddressViewModel(showToEdit: showToEdit))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ShowAddressSearchResults(viewModel: viewModel)
        }
        .navigationTitle("Venue Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.queryText, prompt: Text("Search for venue name or address"))
        .autocorrectionDisabled(true)
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            tryAgainAction: {
                await viewModel.search(withText: viewModel.queryText)
            }
        )
    }
}

struct AddEditShowAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowAddressView(showToEdit: Show.example)
    }
}
