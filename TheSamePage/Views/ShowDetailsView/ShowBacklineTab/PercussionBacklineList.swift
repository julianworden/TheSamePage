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
                ShowBacklineRow(
                    viewModel: viewModel,
                    drumKitBacklineItem: drumKitBacklineItem,
                    title: "Drum Kit",
                    subtitle: "\(drumKitBacklineItem.details). \(drumKitBacklineItem.notes ?? "")",
                    iconName: "drums"
                )

                Divider()
            }
            
            ForEach(viewModel.percussionBacklineItems) { percussionBacklineItem in
                ShowBacklineRow(
                    viewModel: viewModel,
                    backlineItem: percussionBacklineItem,
                    title: percussionBacklineItem.name,
                    subtitle: percussionBacklineItem.notes,
                    iconName: "drums"
                )

                Divider()
            }
        }
    }
}

struct PercussionBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        PercussionBacklineList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
