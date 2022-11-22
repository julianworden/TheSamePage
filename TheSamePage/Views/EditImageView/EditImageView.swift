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
    
    let image: Image?
    
    init(show: Show? = nil, user: User? = nil, band: Band? = nil, image: Image?, updatedImage: Binding<UIImage?>) {
        _viewModel = StateObject(wrappedValue: EditImageViewModel(show: show, user: user, band: band))
        _updatedImage = Binding(projectedValue: updatedImage)
        self.image = image
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            Group {
                switch viewModel.viewState {
                case .displayingView:
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
                case .performingWork:
                    ProgressView()
                default:
                    ErrorMessage(message: ErrorMessageConstants.unknownViewState)
                }
            }
        }
        .navigationBarBackButtonHidden(viewModel.viewState == .performingWork ? true : false)
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    viewModel.imagePickerIsShowing = true
                }
                .disabled(viewModel.editButtonIsDisabled)
            }
        }
        .sheet(
            // TODO: Call viewModel.updateShowImage here instead and lock up UI while function is running with .navigationBackBarDisabled?
            isPresented: $viewModel.imagePickerIsShowing,
            content: {
                ImagePicker(image: $updatedImage, pickerIsShowing: $viewModel.imagePickerIsShowing)
            }
        )
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            tryAgainAction: {
                guard let updatedImage else { return }
                await viewModel.updateImage(withImage: updatedImage)
            }
        )
        .onChange(of: updatedImage) { updatedImage in
            guard let updatedImage else { return }
            Task {
                await viewModel.updateImage(withImage: updatedImage)
            }
        }
        .onChange(of: viewModel.imageUpdateIsComplete) { imageUpdateIsComplete in
            if imageUpdateIsComplete {
                dismiss()
            }
        }
    }
}

struct EditImageView_Previews: PreviewProvider {
    static var previews: some View {
        EditImageView(show: Show.example, image: Image("photo"), updatedImage: .constant(nil))
    }
}
