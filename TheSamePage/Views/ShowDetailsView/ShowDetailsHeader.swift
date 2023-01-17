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
        VStack {
            if viewModel.show.loggedInUserIsShowHost {
                NavigationLink {
                    EditImageView(show: viewModel.show, image: showImage, updatedImage: $updatedImage)
                } label: {
                    if updatedImage == nil {
                        ProfileAsyncImage(url: URL(string: viewModel.show.imageUrl ?? ""), loadedImage: $showImage)
                    } else {
                        // Helps avoid delay from showing updated image
                        Image(uiImage: updatedImage!)
                            .resizable()
                            .scaledToFill()
                            .profileImageStyle()
                    }
                }
            } else {
                // Logged in user is not show host
                ProfileAsyncImage(url: URL(string: viewModel.show.imageUrl ?? ""), loadedImage: .constant(nil))
            }
            
            VStack(spacing: 7) {
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
                        if viewModel.show.loggedInUserIsInvolvedInShow {
                            Button {
                                chatSheetIsShowing = true
                            } label: {
                                Label("Chat", systemImage: "bubble.right")
                            }
                            .fullScreenCover(isPresented: $chatSheetIsShowing) {
                                NavigationView {
                                    ConversationView(show: viewModel.show, showParticipants: viewModel.showParticipants)
                                }
                            }
                        } else if viewModel.show.loggedInUserIsNotInvolvedInShow {
                            // TODO: Make this a sheet instead
                            NavigationLink {
                                EmptyView()
                            } label: {
                                Label("Play This Show", systemImage: "paperplane")
                            }
                        }
                    }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        // Forces the EditImageView to load the showImage properly
        .onChange(of: showImage) { _ in }
        
        // Triggered when the image is updated in the EditImageView sheet
        .onChange(of: updatedImage) { updatedImage in
            Task {
                if let updatedImage {
                    self.showImage = Image(uiImage: updatedImage)
                    // This call is necessary so that the image gets updated visually when it's changed
                    await viewModel.getLatestShowData()
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
