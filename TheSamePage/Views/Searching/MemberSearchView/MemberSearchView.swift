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
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: UiConstants.listRowSpacing) {
                    ForEach(viewModel.fetchedResults, id: \.document) { result in
                        let user = result.document!
                        
                        if user.profileBelongsToLoggedInUser {
                            SearchResultRow(band: nil, user: user, show: nil)
                        } else {
                            NavigationLink {
                                OtherUserProfileView(user: user)
                                    // Necessary because OtherUserProfileView assumes .navigationBarTitleDisplayMode(.large) otherwise
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                SearchResultRow(band: nil, user: user, show: nil)
                            }
                            .tint(.primary)
                        }
                    }
                    .searchable(text: $viewModel.queryText)
                    .autocorrectionDisabled(true)
                }
                .padding(.horizontal)
            }
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
}

struct MemberSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemberSearchView(userIsOnboarding: .constant(true), band: Band.example)
        }
    }
}
