//
//  MemberSearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import SwiftUI

struct MemberSearchView: View {
    @Binding var userIsOnboarding: Bool
    
    @StateObject var viewModel: MemberSearchViewModel
    
    init(userIsOnboarding: Binding<Bool>, band: Band?) {
        _viewModel = StateObject(wrappedValue: MemberSearchViewModel(band: band))
        _userIsOnboarding = Binding(projectedValue: userIsOnboarding)
    }

    var body: some View {
        List {
            ForEach(viewModel.fetchedResults) { result in
                let user = result.searchable as! User
                
                NavigationLink {
                    UserProfileRootView(user: user, band: viewModel.band, bandMember: nil, userIsLoggedOut: $userIsOnboarding, selectedTab: .constant(3))
                } label: {
                    // TODO: Make reusable row for this
                    Text(user.name)
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search) {
            Task {
                do {
                    try await viewModel.getUsers()
                } catch {
                    print(error)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.fetchedResults)
    }
}

struct MemberSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemberSearchView(userIsOnboarding: .constant(true), band: Band.example)
        }
    }
}
