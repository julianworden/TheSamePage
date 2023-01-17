//
//  ShowBacklineRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import SwiftUI

struct ShowBacklineRow: View {
    let title: String
    let subtitle: String?
    let iconName: String
    
    var body: some View {
        if let subtitle {
            ListRowElements(
                title: title,
                subtitle: subtitle,
                iconName: iconName
            )
        } else {
            ListRowElements(
                title: title,
                iconName: iconName
            )
        }
    }
}

struct ShowBacklineRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowBacklineRow(title: "Drums", subtitle: "Kick, snare, toms", iconName: "drums")
    }
}
