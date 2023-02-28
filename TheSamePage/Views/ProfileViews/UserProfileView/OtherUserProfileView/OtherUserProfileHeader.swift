//
//  OtherUserProfileHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct OtherUserProfileHeader: View {
    @ObservedObject var viewModel: OtherUserProfileViewModel
        
    var body: some View {
        if let user = viewModel.user {
            VStack {
                if let userProfileImageUrl = user.profileImageUrl {
                    ProfileAsyncImage(url: URL(string: userProfileImageUrl), loadedImage: .constant(nil))
                } else {
                    NoImageView()
                        .profileImageStyle()
                }
                
                Text(user.name)
                    .font(.title.bold())

                Text(user.fullName)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
            }
            .padding()
        }
    }
}

struct OtherUserProflieHeader_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileHeader(viewModel: OtherUserProfileViewModel(user: User.example))
    }
}
