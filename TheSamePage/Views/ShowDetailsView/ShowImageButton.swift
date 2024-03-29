//
//  ShowImageButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/20/23.
//

import SwiftUI

struct ShowImageButton: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    var body: some View {
        if let show = viewModel.show {
            Button {
                viewModel.editImageConfirmationDialogIsShowing.toggle()
            } label: {
                if viewModel.updatedImage == nil {
                    if let showImageUrl = show.imageUrl {
                        ProfileAsyncImage(url: URL(string: showImageUrl), loadedImage: $viewModel.showImage)
                    } else {
                        NoImageView()
                            .profileImageStyle()
                    }
                } else {
                    Image(uiImage: viewModel.updatedImage!)
                        .resizable()
                        .scaledToFill()
                        .profileImageStyle()
                }
            }
            .confirmationDialog(
                "Edit Image Options",
                isPresented: $viewModel.editImageConfirmationDialogIsShowing,
                titleVisibility: .hidden,
                actions: {
                    Button("Edit Image") { viewModel.editImageViewIsShowing.toggle() }
                    if show.imageUrl != nil {
                        Button("Delete Image", role: .destructive) { viewModel.deleteImageConfirmationAlertIsShowing.toggle() }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            )
            .fullScreenCover(
                isPresented: $viewModel.editImageViewIsShowing,
                onDismiss: {
                    Task {
                        await viewModel.getLatestShowData()
                    }
                },
                content: {
                    EditImageView(
                        show: show,
                        image: viewModel.showImage,
                        updatedImage: $viewModel.updatedImage
                    )
                }
            )
            .alert(
                "Are You Sure?",
                isPresented: $viewModel.deleteImageConfirmationAlertIsShowing,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        Task {
                            await viewModel.deleteShowImage()
                            await viewModel.getLatestShowData()
                        }
                    }
                },
                message: { Text("This band's profile image will be permanently deleted.")}
            )
        }
    }
}

struct ShowImageButton_Previews: PreviewProvider {
    static var previews: some View {
        ShowImageButton(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
