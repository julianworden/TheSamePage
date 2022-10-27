//
//  ShowDetailsRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/26/22.
//

import SwiftUI

struct ShowDetailsStaticRow: View {
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

struct ShowDetailsStaticRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsStaticRow(title: "21+ Only", subtitle: "Don't forget your ID!", iconName: "id")
    }
}
