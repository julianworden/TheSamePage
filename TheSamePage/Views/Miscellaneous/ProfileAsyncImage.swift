//
//  ProfileAsyncImage.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import SwiftUI

struct ProfileAsyncImage: View {
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                    
                    ProgressView()
                }
                .frame(height: 200)
                .padding(.horizontal)
                
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .border(.white, width: 3)
                    .frame(height: 200)
                
            case .failure:
                NoImageView()
                    .padding(.horizontal)
                
            @unknown default:
                NoImageView()
                    .padding(.horizontal)
            }
        }
    }
}

struct ProfileAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileAsyncImage(url: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/the-same-page-9c69e.appspot.com/o/images%2FCB5B7C63-3ACC-4CE6-83A1-AD96D97AB7AB.jpg?alt=media&token=4e0ccba7-6643-4f73-9391-43ee40aaca77"))
    }
}
