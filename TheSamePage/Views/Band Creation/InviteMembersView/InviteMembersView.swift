//
//  InviteMembersView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import SwiftUI

struct InviteMembersView: View {
    @StateObject var viewModel: InviteMembersViewModel
    
    @Binding var userIsOnboarding: Bool
    
    init(userIsOnboarding: Binding<Bool>, band: Band?) {
        _viewModel = StateObject(wrappedValue: InviteMembersViewModel(band: band))
        _userIsOnboarding = Binding(projectedValue: userIsOnboarding)
    }
    
    var body: some View {
        VStack(spacing: 50) {
            NavigationLink {
                MemberSearchView(userIsOnboarding: $userIsOnboarding, band: viewModel.band)
            } label: {
                Text("Tap here to invite your band members to join your band on The Same Page.")
            }
            
            Text("Or")
            
            Button("Do this later") {
                if userIsOnboarding {
                    userIsOnboarding = false
                } else {
                    // TODO: DO whatever to dismiss this view when it's not being shown during onboarding
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct InviteMembersView_Previews: PreviewProvider {
    static var previews: some View {
        InviteMembersView(userIsOnboarding: .constant(true), band: Band.example)
    }
}
