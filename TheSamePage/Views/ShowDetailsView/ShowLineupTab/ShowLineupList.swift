//
//  ShowLineupList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

struct ShowLineupList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(viewModel.showParticipants.enumerated()), id: \.element) { index, showParticipant in
                Button {
                    viewModel.bandProfileSheetIsShowing.toggle()
                } label: {                        
                    ShowLineupRow(viewModel: viewModel, index: index)
                }
                .tint(.primary)
                .fullScreenCover(isPresented: $viewModel.bandProfileSheetIsShowing) {
                    NavigationView {
                        BandProfileView(showParticipant: showParticipant, isPresentedModally: true)
                    }
                }
            }
        }
    }
}

struct ShowLineupList_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
