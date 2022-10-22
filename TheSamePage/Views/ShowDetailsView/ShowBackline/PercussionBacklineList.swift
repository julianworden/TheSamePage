//
//  PercussionBacklineList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/22/22.
//

import SwiftUI

struct PercussionBacklineList: View {
    @ObservedObject var viewModel: ShowBacklineTabViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.drumKitBacklineItems) { drumKitBacklineItem in
                SmallListRow(title: "Drum Kit", subtitle: "\(drumKitBacklineItem.details). \(drumKitBacklineItem.notes ?? "")", iconName: "drums", displayChevron: false)
            }
        }
        .padding(.horizontal)
    }
}

struct PercussionBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        PercussionBacklineList(viewModel: ShowBacklineTabViewModel(show: Show.example))
    }
}
