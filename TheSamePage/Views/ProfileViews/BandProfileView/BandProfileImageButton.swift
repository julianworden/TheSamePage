//
//  BandProfileImageButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/20/23.
//

import SwiftUI

struct BandProfileImageButton: View {
    @ObservedObject var viewModel: BandProfileViewModel

    var body: some View {
        if let band = viewModel.band {
            Button {
                viewModel.editImageConfirmationDialogIsShowing.toggle()
            } label: {
                if viewModel.updatedImage == nil {
                    if let bandImage = band.profileImageUrl {
                        ProfileAsyncImage(url: URL(string: bandImage), loadedImage: $viewModel.bandImage)
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
                    if band.profileImageUrl != nil {
                        Button("Delete Image", role: .destructive) { viewModel.deleteImageConfirmationAlertIsShowing.toggle() }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            )
            .fullScreenCover(
                isPresented: $viewModel.editImageViewIsShowing,
                onDismiss: {
                    Task {
                        await viewModel.getLatestBandData()
                    }
                },
                content: {
                    NavigationStack {
                        EditImageView(
                            band: band,
                            image: viewModel.bandImage,
                            updatedImage: $viewModel.updatedImage
                        )
                    }
                }
            )
            .alert(
                "Are You Sure?",
                isPresented: $viewModel.deleteImageConfirmationAlertIsShowing,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        Task {
                            await viewModel.deleteBandImage()
                            await viewModel.getLatestBandData()
                        }
                    }
                },
                message: { Text("This band's profile image will be permanently deleted.")}
            )
        }
    }
}

struct BandProfileImageButton_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileImageButton(viewModel: BandProfileViewModel(band: Band.example))
    }
}
