//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userController: UserController
    
    @StateObject var viewModel: ProfileViewModel
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(user: User? = nil, band: Band? = nil) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user, band: band))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if viewModel.user != nil {
                        SectionTitle(title: "\(viewModel.user!.firstName) \(viewModel.user!.lastName)")
                    } else if userController.firstName != nil && userController.lastName != nil {
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
                    
                    if viewModel.user != nil && viewModel.user?.id != nil {
                        Button("Invite to your band") {
                            Task {
                                do {
                                    try await viewModel.sendBandInviteNotification()
                                }
                            }
                        }
                    }
                    
                    SectionTitle(title: "Member of")
                    
                    LazyVGrid(columns: columns) {
                        // TODO: Add functionality to find bands the user is a member of and display them here
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                do {
                    // This is needed because HomeView doesn't call initialize user onAppear if the user is onboarding. This is expected.
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
