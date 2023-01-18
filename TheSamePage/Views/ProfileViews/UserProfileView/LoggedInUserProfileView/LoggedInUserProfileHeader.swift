//
//  LoggedInUserProfileHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct LoggedInUserProfileHeader: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @State private var editImageViewIsShowing = false

    var body: some View {
        if let user = loggedInUserController.loggedInUser {
            VStack {
                Button {
                    editImageViewIsShowing.toggle()
                } label: {
                    if loggedInUserController.updatedImage == nil {
                        // User has not updated image
                        if let profileImageUrl = user.profileImageUrl {
                            ProfileAsyncImage(url: URL(string: profileImageUrl), loadedImage: $loggedInUserController.userImage)
                        } else {
                            NoImageView()
                                .profileImageStyle()
                        }
                    } else {
                        // User has updated image
                        Image(uiImage: loggedInUserController.updatedImage!)
                            .resizable()
                            .scaledToFill()
                            .profileImageStyle()
                    }
                }
                .fullScreenCover(
                    isPresented: $editImageViewIsShowing,
                    onDismiss: {
                        Task {
                            await loggedInUserController.getLoggedInUserInfo()
                        }
                    },
                    content: {
                        NavigationView {
                            EditImageView(
                                user: user,
                                image: loggedInUserController.userImage,
                                updatedImage: $loggedInUserController.updatedImage
                            )
                        }
                    }
                )

                Text(user.fullName)
                    .font(.title.bold())
            }
            .padding()
            .onChange(of: loggedInUserController.updatedImage) { updatedImage in
                if let updatedImage {
                    loggedInUserController.userImage = Image(uiImage: updatedImage)
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
