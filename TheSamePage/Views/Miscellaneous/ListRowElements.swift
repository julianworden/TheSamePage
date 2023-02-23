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
    let secondaryText: String?
    let iconName: String
    let iconIsSfSymbol: Bool
    let displayChevron: Bool
    let displayDivider: Bool
    let displayUnreadIndicator: Bool
    
    init(
        title: String,
        subtitle: String? = nil,
        secondaryText: String? = nil,
        iconName: String,
        iconIsSfSymbol: Bool,
        displayChevron: Bool = false,
        displayDivider: Bool = false,
        displayUnreadIndicator: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.secondaryText = secondaryText
        self.iconName = iconName
        self.iconIsSfSymbol = iconIsSfSymbol
        self.displayChevron = displayChevron
        self.displayDivider = displayDivider
        self.displayUnreadIndicator = displayUnreadIndicator
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                if iconIsSfSymbol {
                    Image(systemName: iconName)
                        .imageScale(.large)
                } else {
                    Image(iconName)
                        .listIconStyle()
                }

                VStack(alignment: .leading) {
                    Text(title)
                        .bold(displayUnreadIndicator)
                    
                    if let subtitle,
                       !subtitle.isReallyEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .bold(displayUnreadIndicator)
                    }

                    if let secondaryText,
                       !secondaryText.isReallyEmpty {
                        Text(secondaryText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .bold(displayUnreadIndicator)
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()

                HStack(spacing: 5) {
                    if displayUnreadIndicator {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.blue)
                    }

                    if displayChevron {
                        Image(systemName: "chevron.right")
                    }
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
            iconIsSfSymbol: false,
            displayChevron: true,
            displayDivider: true
        )
    }
}
