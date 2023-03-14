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
        if let show = viewModel.show {
            VStack(spacing: UiConstants.profileHeaderVerticalSpacing) {
                if show.loggedInUserIsShowHost {
                    ShowImageButton(viewModel: viewModel)
                } else if !show.loggedInUserIsShowHost {
                    if let showImageUrl = show.imageUrl {
                        ProfileAsyncImage(url: URL(string: showImageUrl), loadedImage: .constant(viewModel.showImage))
                    } else {
                        NoImageView()
                            .profileImageStyle()
                    }
                }

                Text(show.name)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                HStack {
                    Label(show.venue, systemImage: "music.note.house")
                    Spacer()
                    Label("\(show.city), \(show.state)", systemImage: "mappin")
                }

                HStack {
                    Label(show.formattedDate, systemImage: "calendar")
                    Spacer()
                    Label(show.host, systemImage: "person")
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
}

struct ShowDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsHeader(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
