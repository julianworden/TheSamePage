//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userController: UserController
    
    @StateObject var viewModel = ProfileViewModel()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if userController.firstName != nil && userController.lastName != nil {
                        SectionTitle(title: "\(userController.firstName!) \(userController.lastName!)")
                    } else {
                        SectionTitle(title: "Your Profile")
                    }
                    
                    if userController.profileImageUrl != nil  {
                        ProfileAsyncImage(url: URL(string: userController.profileImageUrl ?? ""))
                    } else {
                        NoImageView()
                            .padding(.horizontal)
                    }
                    
                    SectionTitle(title: "Member of")
                    
                    LazyVGrid(columns: columns) {
                        ForEach(userController.bands) { band in
                            ProfileBandCard(band: band, streamingActionSheetIsShowing: $viewModel.streamingActionSheetIsShowing)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                do {
                    userController.getBands()
                    try await userController.initializeUser()
                } catch {
                    print(error)
                }
            }
            .actionSheet(isPresented: $viewModel.streamingActionSheetIsShowing) {
                ActionSheet(
                    title: Text("Stream"),
                    message: Text("Choose a streaming platform"),
                    buttons: [
                        .cancel(),
                        .default(Text("Spotify")),
                        .default(Text("Apple Music"))
                    ])
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserController())
    }
}
