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
    
    @ObservedObject var viewModel: AddEditShowViewModel
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ShowAddressSearchResultsList(viewModel: viewModel)

        }
        .navigationTitle("Venue Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.queryText, prompt: Text("Search for venue name or address"))
        .autocorrectionDisabled(true)
    }
}

struct AddEditShowAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowAddressView(viewModel: AddEditShowViewModel(showToEdit: nil))
    }
}
