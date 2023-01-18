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
        VStack(spacing: 10) {
            if let band = viewModel.band {
                VStack {
                    if band.loggedInUserIsBandAdmin {
                        // TODO: Make this a fullscreen cover instead and fix bug where no image results in infinite progressview
                        Button {
                            viewModel.editImageViewIsShowing.toggle()
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
                        .fullScreenCover(
                            isPresented: $viewModel.editImageViewIsShowing,
                            onDismiss: {
                                Task {
                                    await viewModel.getLatestBandData()
                                }
                            },
                            content: {
                                NavigationView {
                                    EditImageView(
                                        band: band,
                                        image: viewModel.bandImage,
                                        updatedImage: $viewModel.updatedImage
                                    )
                                }
                            }
                        )
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
                    
                    Text("\(band.genre) from \(band.city), \(band.state)")
                        .font(.title2)
                    
                    if band.loggedInUserIsNotInvolvedWithBand {
                        Button {
                            viewModel.sendShowInviteViewIsShowing = true
                        } label: {
                            Label("Invite to Show", systemImage: "envelope")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .sheet(isPresented: $viewModel.sendShowInviteViewIsShowing) {
                    NavigationView {
                        SendShowInviteView(band: band)
                    }
                    .navigationViewStyle(.stack)
                }
            }
        }
        .onChange(of: viewModel.updatedImage) { updatedImage in
            if let updatedImage {
                viewModel.bandImage = Image(uiImage: updatedImage)
            }
        }
    }
}

struct BandProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileHeader(viewModel: BandProfileViewModel(band: Band.example, showParticipant: nil))
    }
}
