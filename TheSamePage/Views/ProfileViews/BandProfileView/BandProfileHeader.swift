//
//  BandProfileHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandProfileHeader: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    var body: some View {
        if let band = viewModel.band {
            VStack(spacing: UiConstants.profileHeaderVerticalSpacing) {
                if band.loggedInUserIsBandAdmin {
                    BandProfileImageButton(viewModel: viewModel)
                } else if !band.loggedInUserIsBandAdmin {
                    if let bandImage = band.profileImageUrl {
                        ProfileAsyncImage(url: URL(string: bandImage), loadedImage: .constant(viewModel.bandImage))
                    } else {
                        NoImageView()
                            .profileImageStyle()
                    }
                }

                Text(band.name)
                    .font(.title.bold())

                HStack {
                    Label(band.genre, systemImage: "music.quarternote.3")
                    Spacer()
                    Label("\(band.city), \(band.state)", systemImage: "mappin")
                }

                HStack {
                    Label(
                        "\(band.memberUids.count) \(band.memberUids.count == 1 ? "Member" : "Members")",
                        systemImage: "person"
                    )

                    Spacer()

                    Label (
                        "\(viewModel.bandShows.count) \(viewModel.bandShows.count == 1 ? "Show" : "Shows")",
                        systemImage: "music.note.house"
                    )
                }
            }
            .onChange(of: viewModel.updatedImage) { updatedImage in
                if let updatedImage {
                    viewModel.bandImage = Image(uiImage: updatedImage)
                }
            }
        }
    }
}

struct BandProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileHeader(viewModel: BandProfileViewModel(band: Band.example, showParticipant: nil))
    }
}
