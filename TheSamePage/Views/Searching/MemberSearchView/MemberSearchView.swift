//
//  MemberSearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import SwiftUI

struct MemberSearchView: View {
    @Binding var userIsOnboarding: Bool
    
    @StateObject var viewModel = MemberSearchViewModel()

    // TODO: Add done button to toolbar that will end onboarding
    var body: some View {
        List(viewModel.fetchedUsers) { user in
            Text("\(user.firstName) \(user.lastName)")
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
    }
}

struct MemberSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemberSearchView(userIsOnboarding: .constant(true))
        }
    }
}
