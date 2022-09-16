//
//  SectionTitle.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2.bold())
            
            Spacer()
        }
        .padding(.leading)
    }
}

struct SectionTitle_Previews: PreviewProvider {
    static var previews: some View {
        SectionTitle(title: "Shows near you")
            .previewLayout(.fixed(width: 390, height: 60))
    }
}
