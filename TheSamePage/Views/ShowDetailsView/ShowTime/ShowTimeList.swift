//
//  ShowTimeList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

struct ShowTimeList: View {
    @ObservedObject var viewModel: ShowTimeTabViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showMusicStartTime != nil {
                SmallListRow(title: "Music Start: \(viewModel.showMusicStartTime!.formatted(date: .omitted, time: .shortened))", subtitle: nil, iconName: "musicStart", displayChevron: false)
            }
            
            if viewModel.showEndTime != nil {
                SmallListRow(title: "End: \(viewModel.showEndTime!.formatted(date: .omitted, time: .shortened))", subtitle: nil, iconName: "end", displayChevron: false)
            }
            
            if viewModel.showLoadInTime != nil {
                SmallListRow(title: "Load In: \(viewModel.showLoadInTime!.formatted(date: .omitted, time: .shortened))", subtitle: nil, iconName: "loadIn", displayChevron: false)
            }
            
            if viewModel.showDoorsTime != nil {
                SmallListRow(title: "Doors: \(viewModel.showDoorsTime!.formatted(date: .omitted, time: .shortened))", subtitle: nil, iconName: "doors", displayChevron: false)
            }
        }
    }
}

struct ShowTimeList_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeList(viewModel: ShowTimeTabViewModel(show: Show.example))
    }
}
