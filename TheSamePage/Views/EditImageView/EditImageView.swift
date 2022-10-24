//
//  EditImageView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/23/22.
//

import SwiftUI

struct EditImageView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: EditImageViewModel
    
    /// The image that is selected within the ImagePicker
    @Binding var updatedImage: UIImage?
    
    @State private var imagePickerIsShowing = false
    @State private var editButtonIsDisabled = false
    
    let image: Image?
    
    init(show: Show, image: Image?, updatedImage: Binding<UIImage?>) {
        _viewModel = StateObject(wrappedValue: EditImageViewModel(show: show))
        self.image = image
        _updatedImage = Binding(projectedValue: updatedImage)
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .dataLoaded:
                VStack {
                    if let updatedImage {
                        Image(uiImage: updatedImage)
                            .resizable()
                            .scaledToFit()
                    } else if let image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else {
                        NoImageView()
                    }
                }
            case .dataLoading:
                ProgressView()
            case .error(message: let message):
                ErrorMessage(message: "Something went wrong while editing this image. Please check your internet connection and relaunch the app.", errorText: "Error: \(message)")
            default:
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(viewModel.state == .dataLoading ? true : false)
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    imagePickerIsShowing = true
                }
                .disabled(editButtonIsDisabled)
            }
        }
        .sheet(
            // TODO: Call viewModel.updateShowImage here instead and lock up UI while function is running with .navigationBackBarDisabled?
            isPresented: $imagePickerIsShowing,
            content: {
                ImagePicker(image: $updatedImage, pickerIsShowing: $imagePickerIsShowing)
            }
        )
        .onChange(of: updatedImage) { updatedImage in
            Task {
                do {
                    viewModel.state = .dataLoading
                    editButtonIsDisabled = true
                    try await viewModel.updateShowImage(show: viewModel.show, withImage: updatedImage!)
                    viewModel.state = .dataLoaded
                    editButtonIsDisabled = false
                } catch {
                    viewModel.state = .error(message: error.localizedDescription)
                    editButtonIsDisabled = false
                }
            }
        }
    }
}

struct EditImageView_Previews: PreviewProvider {
    static var previews: some View {
        EditImageView(show: Show.example, image: Image("photo"), updatedImage: .constant(nil))
    }
}
