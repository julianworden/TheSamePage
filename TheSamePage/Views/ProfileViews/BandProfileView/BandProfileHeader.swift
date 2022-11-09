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
    
    var body: some View {
        VStack(spacing: 10) {
            if let band = viewModel.band {
                if band.loggedInUserIsBandAdmin {
                    NavigationLink {
                        EditImageView(band: band, image: bandImage, updatedImage: $updatedImage)
                    } label: {
                        if updatedImage == nil {
                            ProfileAsyncImage(url: URL(string: band.profileImageUrl ?? ""), loadedImage: $bandImage)
                        } else {
                            Image(uiImage: updatedImage!)
                                .resizable()
                                .scaledToFit()
                                .border(.white, width: 3)
                                .frame(height: 200)
                                .padding(.horizontal)
                        }
                    }
                } else {
                    ProfileAsyncImage(url: URL(string: band.profileImageUrl ?? ""), loadedImage: .constant(nil))
                }
                
                VStack {
                    Text(band.name)
                        .font(.title.bold())
                    
                    Text("\(band.genre) from \(band.city), \(band.state)")
                }
                
                if let bandBio = band.bio {
                    Text(bandBio)
                        .padding(.horizontal)
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
