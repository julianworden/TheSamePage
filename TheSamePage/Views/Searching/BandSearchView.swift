//
//  BandSearchView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import SwiftUI

/// Used throughout The Same Page when only band searching is needed, as opposed to user
/// and show searching
struct BandSearchView: View {
    @StateObject var viewModel = SearchViewModel()

    @Environment(\.dismiss) var dismiss

    let isPresentedModally: Bool

    init(isPresentedModally: Bool = false) {
        self.isPresentedModally = isPresentedModally
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundColor()
            
            BandSearchResultsList(viewModel: viewModel)
                .searchable(text: $viewModel.queryText, prompt: Text("Search by band name"))
                .autocorrectionDisabled(true)
                .padding(.horizontal)
        }
        .navigationTitle("Band Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
}

struct BandSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BandSearchView(isPresentedModally: true)
        }
    }
}
