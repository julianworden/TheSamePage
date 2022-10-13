//
//  AddShowTimeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

struct AddEditShowTimeView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddEditShowTimeViewModel
    
    init(show: Show, showTimeType: ShowTimeType, showTimeToEdit: Date?) {
        _viewModel = StateObject(wrappedValue: AddEditShowTimeViewModel(show: show, showTimeType: showTimeType, showTimeToEdit: showTimeToEdit))
    }
    
    var body: some View {
        Form {
            DatePicker("Add \(viewModel.showTimeType.rawValue) Time:", selection: $viewModel.showTime, displayedComponents: .hourAndMinute)
        }
        .navigationTitle(viewModel.showTimeToEdit == nil ? "Add Time" : "Edit Time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        do {
                            try await viewModel.addShowTime(ofType: viewModel.showTimeType)
                            dismiss()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
}


struct AddShowTimeView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowTimeView(show: Show.example, showTimeType: .loadIn, showTimeToEdit: nil)
    }
}
