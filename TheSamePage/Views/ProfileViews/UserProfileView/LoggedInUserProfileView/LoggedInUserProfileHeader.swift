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
            VStack(spacing: UiConstants.profileHeaderVerticalSpacing) {
                LoggedInUserProfileImage()

                Text(user.name)
                    .font(.title.bold())

                Text(user.fullName)
                    .font(.title3)
                    .foregroundColor(.secondary)

                HStack {
                    Label("\(loggedInUserController.allBands.count) \(loggedInUserController.allBands.count == 1 ? "Band" : "Bands")", systemImage: "person.3")
                    Spacer()
                    Label("\(loggedInUserController.allShows.count) \(loggedInUserController.allShows.count == 1 ? "Show" : "Shows")", systemImage: "music.note.house")
                }
            }
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
