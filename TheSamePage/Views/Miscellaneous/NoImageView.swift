//
//  NoImageView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/20/22.
//

import SwiftUI

/// Presented when an image either hasn't been selected or could not be loaded.
struct NoImageView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(uiColor: .lightGray.withAlphaComponent(0.25)))
            
            Image(systemName: "camera")
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .foregroundColor(.primary)
        }
        .frame(height: 200)
    }
}

struct NoImageView_Previews: PreviewProvider {
    static var previews: some View {
        NoImageView()
    }
}
