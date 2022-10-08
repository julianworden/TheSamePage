//
//  ListRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import Foundation

class ListRowViewModel: ObservableObject {
    let rowTitle: String
    let displayChevron: Bool
    let rowIndex: Int
    let listItemCount: Int
    var rowSubtitle: String?
    var rowIconName: String?
    
    init(
        title: String,
        subtitle: String?,
        iconName: String?,
        displayChevron: Bool,
        rowIndex: Int,
        listItemCount: Int
    ) {
        self.rowTitle = title
        self.rowSubtitle = subtitle
        self.rowIconName = iconName
        self.displayChevron = displayChevron
        self.rowIndex = rowIndex
        self.listItemCount = listItemCount
    }
}
