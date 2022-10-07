//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct UserProfileRootView: View {
    @StateObject var viewModel: UserProfileRootViewModel
    
    @Binding var userIsLoggedOut: Bool
    @Binding var selectedTab: Int
        
    init(user: User?, bandMember: BandMember?, userIsLoggedOut: Binding<Bool>, selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: UserProfileRootViewModel(user: user, bandMember: bandMember))
        _userIsLoggedOut = Binding(projectedValue: userIsLoggedOut)
        _selectedTab = Binding(projectedValue: selectedTab)
    }
    
    var body: some View {
            if viewModel.user == nil && viewModel.bandMember == nil {
                LoggedInUserProfileView(
                    userIsLoggedOut: $userIsLoggedOut,
                    selectedTab: $selectedTab
                )
            } else {
                OtherUserProfileView(
                    user: viewModel.user,
                    bandMember: viewModel.bandMember
                )
            }
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileRootView(user: User.example, bandMember: BandMember.example, userIsLoggedOut: .constant(false), selectedTab: .constant(3))
    }
}
