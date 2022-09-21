//
//  NoImageView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/20/22.
//

import SwiftUI

struct NoImageView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray)
            
            Image(systemName: "camera")
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .foregroundColor(.white)
        }
        .frame(height: 200)
    }
}

struct NoImageView_Previews: PreviewProvider {
    static var previews: some View {
        NoImageView()
    }
}
