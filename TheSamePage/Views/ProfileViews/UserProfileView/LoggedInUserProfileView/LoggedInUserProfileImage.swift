//
//  LoggedInUserProfileImage.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/20/23.
//

import SwiftUI

struct LoggedInUserProfileImage: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @State private var editImageViewIsShowing = false
    @State private var editImageConfirmationDialogIsShowing = false
    @State private var deleteImageConfirmationAlertIsShowing = false

    var body: some View {
        if let user = loggedInUserController.loggedInUser {
            Button {
                editImageConfirmationDialogIsShowing.toggle()
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
            .confirmationDialog("Edit Image Options", isPresented: $editImageConfirmationDialogIsShowing, titleVisibility: .hidden) {
                Button("Edit Image") { editImageViewIsShowing.toggle() }
                if user.profileImageUrl != nil {
                    Button("Delete Image", role: .destructive) { deleteImageConfirmationAlertIsShowing.toggle() }
                }
                Button("Cancel", role: .cancel) { }
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
            .alert(
                "Are You Sure?",
                isPresented: $deleteImageConfirmationAlertIsShowing,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        Task {
                            await loggedInUserController.deleteProfileImage()
                            await loggedInUserController.getLoggedInUserInfo()
                        }
                    }
                },
                message: { Text("Your profile image will be permanently deleted.")}
            )
        }
    }
}

struct LoggedInUserProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserProfileImage()
    }
}
