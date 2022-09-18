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
    
    @State private var streamingActionSheetIsShowing = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SectionTitle(title: "Julian Worden")
                    
                    Image("profilePicture")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 158)
                    
                    SectionTitle(title: "Member of")
                    
                    LazyVGrid(columns: columns) {
                        ForEach(userController.bands) { band in
                            ProfileBandCard(band: band, streamingActionSheetIsShowing: $streamingActionSheetIsShowing)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                userController.getBands()
            }
            .actionSheet(isPresented: $streamingActionSheetIsShowing) {
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
