//
//  ShowDetailsHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

struct ShowDetailsHeader: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    /// The image loaded from the ProfileAsyncImage
    @State private var showImage: Image?
    /// A new image set within EditImageView
    @State private var updatedImage: UIImage?
    
    var body: some View {
        VStack {
            if viewModel.show.loggedInUserIsShowHost {
                NavigationLink {
                    EditImageView(show: viewModel.show, image: showImage, updatedImage: $updatedImage)
                } label: {
                    if updatedImage == nil {
                        ProfileAsyncImage(url: URL(string: viewModel.showImageUrl ?? ""), loadedImage: $showImage)
                    } else {
                        // Helps avoid delay from showing updated image
                        Image(uiImage: updatedImage!)
                            .resizable()
                            .scaledToFit()
                            .border(.white, width: 3)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                }
            } else {
                if updatedImage == nil {
                    ProfileAsyncImage(url: URL(string: viewModel.showImageUrl ?? ""), loadedImage: $showImage)
                } else {
                    // Helps avoid delay from showing updated image
                    Image(uiImage: updatedImage!)
                        .resizable()
                        .scaledToFit()
                        .border(.white, width: 3)
                        .frame(height: 200)
                        .padding(.horizontal)
                }
            }
            
            VStack(spacing: 2) {
                Text(viewModel.showName)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("At \(viewModel.showVenue) in \(viewModel.showCity), \(viewModel.showState) on \(viewModel.showDate)")
                    .font(.title2)
                
                // TODO: Make this a sheet instead
                if viewModel.show.loggedInUserIsNotInvolvedInShow {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Text("Play this show")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        // Forces the EditImageView to load the showImage properly
        .onChange(of: showImage) { _ in }
        
        // Triggered when the image is updated in the EditImageView sheet
        .onChange(of: updatedImage) { updatedImage in
            if let updatedImage {
                self.showImage = Image(uiImage: updatedImage)
                // This call is necessary so that the image gets updated visually when it's changed
                viewModel.addShowListener()
            }
        }
    }
}

struct ShowDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsHeader(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
