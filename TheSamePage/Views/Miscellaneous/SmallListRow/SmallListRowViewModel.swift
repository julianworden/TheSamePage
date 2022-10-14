//
//  SmallListRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import Foundation

class SmallListRowViewModel: ObservableObject {
    @Published var rowTitle: String
    @Published var displayChevron: Bool
    @Published var rowSubtitle: String?
    @Published var rowIconName: String?
    
    init(
        title: String,
        subtitle: String?,
        iconName: String?,
        displayChevron: Bool
    ) {
        self.rowTitle = title
        self.rowSubtitle = subtitle
        self.rowIconName = iconName
        self.displayChevron = displayChevron
    }
}
