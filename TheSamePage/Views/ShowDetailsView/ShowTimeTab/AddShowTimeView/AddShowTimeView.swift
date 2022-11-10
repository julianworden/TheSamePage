
//  AddShowTimeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

struct AddShowTimeView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddShowTimeViewModel
    
    init(show: Show, showTimeType: ShowTimeType) {
        _viewModel = StateObject(wrappedValue: AddShowTimeViewModel(show: show, showTimeType: showTimeType))
    }
    
    var body: some View {
        Form {
            DatePicker("\(viewModel.showTimeType.rawValue) Time", selection: $viewModel.showTime, displayedComponents: .hourAndMinute)
        }
        .navigationTitle("Edit Show Time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", role: .cancel) {
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
        AddShowTimeView(show: Show.example, showTimeType: .loadIn)
    }
}
