//
//  ShowDetailsHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

struct ShowDetailsHeader: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
        
    var body: some View {
        VStack {
            ProfileAsyncImage(url: URL(string: viewModel.showImageUrl ?? ""))
            
            VStack(spacing: 2) {
                Text(viewModel.showName)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("\(viewModel.showVenue) | \(viewModel.showCity), \(viewModel.showState)")
                    .font(.title2)
                
                if let showDate = viewModel.showDate {
                    Text("\(showDate)")
                        .font(.title2)
                }
                
                // I'd like for this to be a sheet instead, but when I do this I get unexpected navigation behavior
                if viewModel.show.loggedInUserIsNotInvolvedInShow {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Text("Play this show")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical)
                }
            }
        }
    }
}

struct ShowDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsHeader(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
