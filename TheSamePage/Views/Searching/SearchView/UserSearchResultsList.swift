//
//  UserSearchResultsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import SwiftUI
import Typesense

struct UserSearchResultsList: View {
    @Environment(\.isSearching) var isSearching
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()

            case .dataLoaded, .error, .displayingView:
                ScrollView {
                    VStack(spacing: UiConstants.listRowSpacing) {
                        ForEach(viewModel.fetchedUsers, id: \.document) { result in
                            let user = result.document!
                            
                            if user.profileBelongsToLoggedInUser {
                                SearchResultRow(user: user)
                            } else {
                                NavigationLink {
                                    OtherUserProfileView(user: user)
                                } label: {
                                    SearchResultRow(user: user)
                                }
                                .tint(.primary)
                            }

                            Divider()
                        }
                    }
                }
                
            case .dataNotFound:
                NoDataFoundMessage(message: "No results.")
                
            default:
                ErrorMessage(message: "Invalid viewState")
            }
        }
        .onChange(of: viewModel.queryText) { _ in
            Task {
                await viewModel.fetchUsers()
            }
        }
        .onChange(of: isSearching) { _ in
            viewModel.isSearching.toggle()
        }
    }
}


struct UserSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchResultsList(viewModel: SearchViewModel())
    }
}
