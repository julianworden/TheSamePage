//
//  SmallListRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import SwiftUI

struct SmallListRow: View {
    @StateObject var viewModel: SmallListRowViewModel

    init(
        title: String,
        subtitle: String?,
        iconName: String?,
        displayChevron: Bool
    ) {
        _viewModel = StateObject(
            wrappedValue: SmallListRowViewModel(
                title: title,
                subtitle: subtitle,
                iconName: iconName,
                displayChevron: displayChevron
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if let rowIconName = viewModel.rowIconName {
                    Image(rowIconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .padding(.leading, 5)
                }
                
                VStack(alignment: .leading) {
                    Text(viewModel.rowTitle)
                    
                    if let rowSubtitle = viewModel.rowSubtitle {
                        Text(rowSubtitle)
                            .font(.caption)
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()

                if viewModel.displayChevron {
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                }
            }
            .padding(6)
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
