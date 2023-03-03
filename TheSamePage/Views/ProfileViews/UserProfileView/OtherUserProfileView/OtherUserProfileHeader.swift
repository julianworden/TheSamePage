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
            VStack(spacing: UiConstants.profileHeaderVerticalSpacing) {
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

                HStack {
                    Label("\(viewModel.bands.count) \(viewModel.bands.count == 1 ? "Band" : "Bands")", systemImage: "person.3")
                    Spacer()
                    Label("\(viewModel.shows.count) \(viewModel.shows.count == 1 ? "Show" : "Shows")", systemImage: "music.note.house")
                }
            }
            .padding(.horizontal)
        }
    }
}

struct OtherUserProflieHeader_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileHeader(viewModel: OtherUserProfileViewModel(user: User.example))
    }
}
