//
//  BandProfileHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandProfileHeader: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    @State private var bandImage: Image?
    @State private var updatedImage: UIImage?
    @State private var sendShowInviteViewIsShowing = false
    
    var body: some View {
        VStack(spacing: 10) {
            if let band = viewModel.band {
                VStack {
                    if band.loggedInUserIsBandAdmin {
                        NavigationLink {
                            EditImageView(band: band, image: bandImage, updatedImage: $updatedImage)
                        } label: {
                            if updatedImage == nil {
                                ProfileAsyncImage(url: URL(string: band.profileImageUrl ?? ""), loadedImage: $bandImage)
                            } else {
                                Image(uiImage: updatedImage!)
                                    .resizable()
                                    .scaledToFill()
                                    .profileImageStyle()
                            }
                        }
                    } else {
                        ProfileAsyncImage(url: URL(string: band.profileImageUrl ?? ""), loadedImage: .constant(nil))
                    }
                    
                    Text(band.name)
                        .font(.title.bold())
                    
                    Text("\(band.genre) from \(band.city), \(band.state)")
                        .font(.title2)
                    
                    if band.loggedInUserIsNotInvolvedWithBand {
                        Button {
                            sendShowInviteViewIsShowing = true
                        } label: {
                            Label("Invite to Show", systemImage: "envelope")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .sheet(isPresented: $sendShowInviteViewIsShowing) {
                    SendShowInviteView(band: band)
                }
            }
        }
        .onChange(of: bandImage) { _ in }
        .onChange(of: updatedImage) { updatedImage in
            if let updatedImage {
                self.bandImage = Image(uiImage: updatedImage)
                viewModel.addBandListener()
            }
        }
    }
}

struct BandProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileHeader(viewModel: BandProfileViewModel(band: Band.example, showParticipant: nil))
    }
}
