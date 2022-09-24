//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var userController: UserController
    
    @StateObject var viewModel: UserProfileViewModel
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(user: User? = nil, band: Band? = nil) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(user: user, band: band))
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
                                    try viewModel.sendBandInviteNotification()
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                    
                    if let bands = userController.bands {
                        
                        SectionTitle(title: "Member of")
                    
                        LazyVGrid(columns: columns) {
                            ForEach(bands) { band in
                                NavigationLink {
                                    
                                } label: {
                                    UserProfileBandCard(band: band)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                do {
                    // This is needed because HomeView doesn't call initialize user onAppear if the user is onboarding. This is expected.
                    try await userController.initializeUser()
                    try await userController.getBands()
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
        UserProfileView()
            .environmentObject(UserController())
    }
}
