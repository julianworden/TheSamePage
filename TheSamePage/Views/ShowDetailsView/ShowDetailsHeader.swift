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
    @State private var chatSheetIsShowing = false
    
    var body: some View {
        let show = viewModel.show
        
        VStack {
            if show.loggedInUserIsShowHost {
                NavigationLink {
                    EditImageView(show: show, image: showImage, updatedImage: $updatedImage)
                } label: {
                    if updatedImage == nil {
                        ProfileAsyncImage(url: URL(string: show.imageUrl ?? ""), loadedImage: $showImage)
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
                // Logged in user is not show host
                ProfileAsyncImage(url: URL(string: show.imageUrl ?? ""), loadedImage: .constant(nil))
            }
            
            if show.loggedInUserIsInvolvedInShow {
                Button {
                    chatSheetIsShowing = true
                } label: {
                    Label("Chat", systemImage: "bubble.right")
                }
                .buttonStyle(.bordered)
            }
            
            VStack(spacing: 2) {
                Text(show.name)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("At \(show.venue) in \(show.city), \(show.state) on \(show.formattedDate)")
                    .font(.title2)
                
                // TODO: Make this a sheet instead
                if show.loggedInUserIsNotInvolvedInShow {
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
        .fullScreenCover(isPresented: $chatSheetIsShowing) {
            NavigationView {
                ConversationView(show: show, showParticipants: viewModel.showParticipants)
            }
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
