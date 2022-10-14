//
//  SmallListRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import SwiftUI

struct SmallListRow: View {
//    @StateObject var viewModel: SmallListRowViewModel
    
    // TODO: Put these properties back into the viewmodel if it's not causing the update issue
    @State private var title: String
    @State private var subtitle: String?
    @State private var iconName: String?
    @State private var displayChevron: Bool
    
    init(
        title: String,
        subtitle: String?,
        iconName: String?,
        displayChevron: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.displayChevron = displayChevron
//        _viewModel = StateObject(
//            wrappedValue: SmallListRowViewModel(
//                title: title,
//                subtitle: subtitle,
//                iconName: iconName,
//                displayChevron: displayChevron
//            )
//        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if let rowIconName = iconName {
                    Image(rowIconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .padding(.leading, 10)
                }
                
                VStack(alignment: .leading) {
                    Text(title)
                    
                    if let rowSubtitle = subtitle {
                        Text(rowSubtitle)
                            .font(.caption)
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()

                if displayChevron {
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                }
            }
            .frame(height: 50)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            
            Divider()
        }
    }
}

struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        SmallListRow(title: "Julian Worden", subtitle: "Vocals", iconName: "vocals", displayChevron: true)
    }
}
