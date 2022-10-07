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
            ForEach(viewModel.fetchedResults, id: \.document) { result in
                let user = result.document!
                
                NavigationLink {
                    UserProfileRootView(user: user, bandMember: nil, userIsLoggedOut: $userIsOnboarding, selectedTab: .constant(3))
                } label: {
                    SearchResultRow(band: nil, user: user, show: nil)
                }
            }
        }
        .searchable(text: $viewModel.queryText)
        .onChange(of: viewModel.queryText) { query in
            Task {
                do {
                    try await viewModel.fetchUsers(searchQuery: query)
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct MemberSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemberSearchView(userIsOnboarding: .constant(true), band: Band.example)
        }
    }
}
