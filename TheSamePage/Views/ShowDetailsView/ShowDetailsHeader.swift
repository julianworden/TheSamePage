//
//  ShowDetailsHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

struct ShowDetailsHeader: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    
    var body: some View {
        VStack(spacing: UiConstants.profileHeaderVerticalSpacing) {
            if viewModel.show.loggedInUserIsShowHost {
                // TODO: Make this a fullscreencover and fix bug where no image results in infinite progressview
                Button {
                    viewModel.editImageViewIsShowing.toggle()
                } label: {
                    if viewModel.updatedImage == nil {
                        if let showImageUrl = viewModel.show.imageUrl {
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
                .fullScreenCover(
                    isPresented: $viewModel.editImageViewIsShowing,
                    onDismiss: {
                        Task {
                            await viewModel.getLatestShowData()
                        }
                    },
                    content: {
                        NavigationView {
                            EditImageView(
                                show: viewModel.show,
                                image: viewModel.showImage,
                                updatedImage: $viewModel.updatedImage
                            )
                        }
                    }
                )
            } else if !viewModel.show.loggedInUserIsShowHost {
                // Logged in user is not show host
                if let showImageUrl = viewModel.show.imageUrl {
                    ProfileAsyncImage(url: URL(string: showImageUrl), loadedImage: .constant(viewModel.showImage))
                } else {
                    NoImageView()
                        .profileImageStyle()
                }
            }
            
            Text(viewModel.show.name)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            HStack {
                Label(viewModel.show.venue, systemImage: "music.note.house")
                Spacer()
                Label("\(viewModel.show.city), \(viewModel.show.state)", systemImage: "mappin")
            }

            HStack {
                Label(viewModel.show.formattedDate, systemImage: "calendar")
                Spacer()
                Label(viewModel.show.host, systemImage: "person")
            }
        }
        .padding(.horizontal)
        // Triggered when the image is updated in the EditImageView sheet
        .onChange(of: viewModel.updatedImage) { updatedImage in
            if let updatedImage {
                viewModel.showImage = Image(uiImage: updatedImage)
            }
        }
    }
}

struct ShowDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsHeader(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
