//
//  AddEditBandView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

// TODO: Ask user if they play in this band.

import SwiftUI

struct AddEditBandView: View {
    @StateObject var viewModel = AddEditBandViewModel()
    
    @State private var imagePickerIsShowing = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        Form {
            Section("Info") {
                ImageSelectionButton(imagePickerIsShowing: $imagePickerIsShowing, selectedImage: $selectedImage)
                TextField("Name", text: $viewModel.bandName)
            }
            
            Section("Location") {
                TextField("City", text: $viewModel.bandCity)
                TextField("State", text: $viewModel.bandState)
            }
            
            Section {
                Button("Create Band") {
                    Task {
                        do {
                            try await viewModel.createBand(withImage: selectedImage)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        .navigationTitle("Create a band")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $imagePickerIsShowing) {
            ImagePicker(image: $selectedImage, pickerIsShowing: $imagePickerIsShowing)
        }
    }
}

struct AddEditBandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddEditBandView()
        }
    }
}
