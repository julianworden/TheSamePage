//
//  ListRowElements.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

/// Contains the elements that make up a list row.
///
/// This view can be used under a few different circumstances. First, if a transparent background is
/// desired, this row will be used. It may also be used in conjunction with a row view. This may seem
/// redundant at some points, but it's necessary for rows that require access to their parent's view model
/// for UI updates.
struct ListRowElements: View {
    let title: String
    let subtitle: String?
    let iconName: String
    let displayChevron: Bool
    let displayDivider: Bool
    
    init(
        title: String,
        subtitle: String? = nil,
        iconName: String,
        displayChevron: Bool = false,
        displayDivider: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.displayChevron = displayChevron
        self.displayDivider = displayDivider
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
               Image(iconName)
                    .listIconStyle()
                
                VStack(alignment: .leading) {
                    Text(title)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                if displayChevron {
                    Image(systemName: "chevron.right")
                }
            }
            
            if displayDivider {
                Divider()
            }
        }
    }
}

struct ListRowElements_Previews: PreviewProvider {
    static var previews: some View {
        ListRowElements(
            title: "Julian Worden",
            subtitle: "Vocals",
            iconName: "vocals",
            displayChevron: true,
            displayDivider: true
        )
    }
}
