//
//  UserSearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import SwiftUI

/// Used throughout The Same Page when only user searching is needed, as opposed to band
/// and show searching
struct UserSearchView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel = SearchViewModel()

    let isPresentedModally: Bool

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundColor()
            
            UserSearchResultsList(viewModel: viewModel)
                .searchable(text: $viewModel.queryText, prompt: Text("Search by username"))
                .autocorrectionDisabled(true)
                .padding(.horizontal)
        }
        .navigationTitle("Search for User")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isPresentedModally {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MemberSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserSearchView(isPresentedModally: true)
        }
    }
}
