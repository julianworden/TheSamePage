//
//  ShowDetailsRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/26/22.
//

import SwiftUI

/// A row for the ShowDetailsTab that is used for boolean show information,
/// such as whether or not a show has a bar or is 21+.
struct ShowDetailsStaticRow: View {
    let title: String
    let subtitle: String?
    let iconName: String
    
    var body: some View {
        ListRowElements(
            title: title,
            subtitle: subtitle,
            iconName: iconName
        )
    }
}

struct ShowDetailsStaticRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsStaticRow(title: "21+ Only", subtitle: "Don't forget your ID!", iconName: "id")
    }
}
