//
//  ShowLineupTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowLineupTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.showSlotsRemainingMessage)
                    .font(.title3.bold())
                    .padding()
                
                Spacer()
                
                if viewModel.show.loggedInUserIsShowHost {
                    NavigationLink {
                        BandSearchView()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .padding(.trailing)
                }
            }
            
            if !viewModel.showLineup.isEmpty {
                ShowLineupList(viewModel: viewModel)
            } else if viewModel.show.loggedInUserIsShowHost {
                Text("No bands are playing this show yet. Click the plus button to invite bands to play!")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding()
            } else if viewModel.show.loggedInUserIsNotInvolvedInShow {
                Text("No bands are playing this show yet. Only the show's host can invite bands to play.")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

struct ShowLineupTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
