//
//  MemberSearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import SwiftUI

struct MemberSearchView: View {    
//    @Binding var userIsOnboarding: Bool
    
    @StateObject var viewModel = SearchViewModel()
    
//    init(userIsOnboarding: Binding<Bool>, band: Band?) {
//        _viewModel = StateObject(wrappedValue: MemberSearchViewModel(band: band))
//        _userIsOnboarding = Binding(projectedValue: userIsOnboarding)
//    }

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
    }
}

struct MemberSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemberSearchView()
        }
    }
}
