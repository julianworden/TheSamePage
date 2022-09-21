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
                    SectionTitle(title: "\(userController.firstName) \(userController.lastName)")
                    
                    AsyncImage(url: URL(string: userController.profileImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        case .failure:
                            NoImageView()
                        @unknown default:
                            NoImageView()
                        }
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
