//
//  PercussionBacklineList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/22/22.
//

import SwiftUI

struct PercussionBacklineList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(viewModel.drumKitBacklineItems) { drumKitBacklineItem in
                ShowBacklineRow(title: "Drum Kit", subtitle: "\(drumKitBacklineItem.details). \(drumKitBacklineItem.notes ?? "")", iconName: "drums")
            }
            
            ForEach(viewModel.percussionBacklineItems) { percussionBacklineItem in
                ShowBacklineRow(title: percussionBacklineItem.name, subtitle: percussionBacklineItem.notes, iconName: "drums")
            }
        }
    }
}

struct PercussionBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        PercussionBacklineList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
