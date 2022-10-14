//
//  ShowTimeList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

@MainActor
struct ShowTimeList: View {
    @ObservedObject var viewModel: ShowTimeTabViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showLoadInTime != nil {
                ShowTimeRow(viewModel: viewModel, showTimeType: .loadIn)
            }
                
            if viewModel.showDoorsTime != nil {
                ShowTimeRow(viewModel: viewModel, showTimeType: .doors)
            }
            
            if viewModel.showMusicStartTime != nil {
                ShowTimeRow(viewModel: viewModel, showTimeType: .musicStart)
            }
            
            if viewModel.showEndTime != nil {
                ShowTimeRow(viewModel: viewModel, showTimeType: .end)
            }
        }
    }
}

    
struct ShowTimeList_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeList(viewModel: ShowTimeTabViewModel(show: Show.example))
    }
}
