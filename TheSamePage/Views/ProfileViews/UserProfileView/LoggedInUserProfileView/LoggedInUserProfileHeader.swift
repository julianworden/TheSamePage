//
//  LoggedInUserProfileHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct LoggedInUserProfileHeader: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    /// The image loaded from the ProfileAsyncImage
    @State private var userImage: Image?
    /// A new image set within EditImageView
    @State private var updatedImage: UIImage?
    
    var body: some View {
        if let user = loggedInUserController.loggedInUser {
            HStack {
                VStack(alignment: .leading) {
                    NavigationLink {
                        EditImageView(user: user, image: userImage, updatedImage: $updatedImage)
                    } label: {
                        if updatedImage == nil {
                            ProfileAsyncImage(url: URL(string: user.profileImageUrl ?? ""), loadedImage: $userImage)
                        } else {
                            Image(uiImage: updatedImage!)
                                .resizable()
                                .scaledToFit()
                                .border(.white, width: 3)
                                .frame(height: 200)
                                .padding(.horizontal)
                        }
                    }
                    
                    Text(user.fullName)
                        .font(.title2.bold())
                }
                
                Spacer()
            }
            .padding()
            .onChange(of: userImage) { _ in }
            .onChange(of: updatedImage) { updatedImage in
                if let updatedImage {
                    self.userImage = Image(uiImage: updatedImage)
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
