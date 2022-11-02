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
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading) {
                    Text(title)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
}

struct ShowBacklineRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowBacklineRow(title: "Drums", subtitle: "Kick, snare, toms", iconName: "drums")
    }
}
