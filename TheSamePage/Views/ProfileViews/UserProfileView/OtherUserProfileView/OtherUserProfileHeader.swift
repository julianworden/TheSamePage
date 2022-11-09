//
//  OtherUserProfileHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct OtherUserProfileHeader: View {
    @ObservedObject var viewModel: OtherUserProfileViewModel
    
    @State private var sendBandInviteViewIsShowing = false
    
    var body: some View {
        if let user = viewModel.user {
            VStack {
                ProfileAsyncImage(url: URL(string: user.profileImageUrl ?? ""), loadedImage: .constant(nil))
                
                Text(user.fullName)
                    .font(.title.bold())
                
                Button {
                    sendBandInviteViewIsShowing = true
                } label: {
                    Label("Invite to Band", systemImage: "envelope")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .sheet(isPresented: $sendBandInviteViewIsShowing) {
                // Force unwrap is safe because the button that shows this sheet is already checking if user is nil
                NavigationView {
                    SendBandInviteView(user: user)
                }
            }
        }
    }
}

struct OtherUserProflieHeader_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileHeader(viewModel: OtherUserProfileViewModel(user: User.example))
    }
}
