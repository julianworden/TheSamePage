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
                Button("Edit Band Info") {
                    editBandSheetIsShowing = true
                }
                
                if !band.loggedInUserIsBandAdmin {
                    Button("Leave band", role: .destructive) {
                        leaveBandAlertIsShowing = true
                    }
                }
                
                if band.loggedInUserIsBandAdmin {
                    // TODO: Add logic to make someone else band admin
                }
            }
        }
        .navigationTitle("Band Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $editBandSheetIsShowing) {
            NavigationView {
                AddEditBandView(bandToEdit: band)
            }
        }
        .alert(
            "Are you sure?",
            isPresented: $leaveBandAlertIsShowing,
            actions: {
                Button("Cancel", role: .cancel) { }
                Button("Leave Band", role: .destructive) {
                    Task {
                        await viewModel.leaveBand(); dismiss()
                    }
                }
            }, message: {
                Text("If you leave \(band.name), you will no longer have access to \(band.name)'s chats, shows, etc.")
            }
        )
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            tryAgainAction: { await viewModel.leaveBand() }
        )
    }
}

struct BandSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BandSettingsView(band: Band.example)
    }
}
