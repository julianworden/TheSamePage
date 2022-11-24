//
//  LoggedInUserProfileHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct LoggedInUserProfileHeader: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    var body: some View {
        if let user = loggedInUserController.loggedInUser {
            VStack {
                NavigationLink {
                    EditImageView(user: user, image: loggedInUserController.userImage, updatedImage: $loggedInUserController.updatedImage)
                } label: {
                    if loggedInUserController.updatedImage == nil {
                        ProfileAsyncImage(url: URL(string: user.profileImageUrl ?? ""), loadedImage: $loggedInUserController.userImage)
                    } else {
                        Image(uiImage: loggedInUserController.updatedImage!)
                            .resizable()
                            .scaledToFill()
                            .profileImageStyle()
                    }
                }
                
                Text(user.fullName)
                    .font(.title.bold())
            }
            .padding()
            .onChange(of: loggedInUserController.userImage) { _ in }
            .onChange(of: loggedInUserController.updatedImage) { updatedImage in
                if let updatedImage {
                    loggedInUserController.userImage = Image(uiImage: updatedImage)
                    loggedInUserController.addUserListener()
                }
            }
        }
    }
}

struct LoggedInUserProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserProfileHeader()
    }
}
