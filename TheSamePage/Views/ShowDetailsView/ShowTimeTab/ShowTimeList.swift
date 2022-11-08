//
//  ShowTimeList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

@MainActor
struct ShowTimeList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        let show = viewModel.show
        
        VStack(spacing: UiConstants.listRowSpacing) {
            if show.loadInTime != nil {
                ShowTimeRow(viewModel: viewModel, showTimeType: .loadIn)
            }
                
            if show.doorsTime != nil {
                ShowTimeRow(viewModel: viewModel, showTimeType: .doors)
            }
            
            if show.musicStartTime != nil {
                ShowTimeRow(viewModel: viewModel, showTimeType: .musicStart)
            }
            
            if show.endTime != nil {
                ShowTimeRow(viewModel: viewModel, showTimeType: .end)
            }
        }
    }
}

    
struct ShowTimeList_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
