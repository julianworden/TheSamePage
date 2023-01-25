//
//  BandSettingsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/13/22.
//

import SwiftUI

struct BandSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: BandSettingsViewModel
    
    @State private var editBandSheetIsShowing = false
    @State private var leaveBandAlertIsShowing = false
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: BandSettingsViewModel(band: band))
    }
    
    var body: some View {
        let band = viewModel.band
        
        Form {
            Section {
                NavigationLink {
                    AddEditBandView(bandToEdit: band)
                } label: {
                    Text("Edit Band Info")
                }
                
                if band.loggedInUserIsBandAdmin {
                    // TODO: Add logic to make someone else band admin
                }
            }
        }
        .navigationTitle("Band Settings")
        .navigationBarTitleDisplayMode(.inline)
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
    }
}

struct BandSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BandSettingsView(band: Band.example)
    }
}
