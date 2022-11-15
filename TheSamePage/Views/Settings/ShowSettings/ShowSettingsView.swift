//
//  ShowSettingsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/14/22.
//

import SwiftUI

struct ShowSettingsView: View {
    @StateObject var viewModel: ShowSettingsViewModel
    
    @State private var addEditShowSheetIsShowing = false
    @State private var leaveShowAlertIsShowing = false
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowSettingsViewModel(show: show))
    }
    
    var body: some View {
        let show = viewModel.show
        
        Form {
            Button("Edit Show") {
                addEditShowSheetIsShowing = true
            }
            
            Button("Cancel Show", role: .cancel) {
                viewModel.cancelShow()
            }
        }
        .sheet(isPresented: $addEditShowSheetIsShowing) {
            NavigationView {
                AddEditShowView(showToEdit: show)
                    .navigationViewStyle(.stack)
            }
        }
    }
}

struct ShowSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowSettingsView(show: Show.example)
    }
}
