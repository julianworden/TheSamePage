//
//  ProfileAsyncImage.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import SwiftUI

struct ProfileAsyncImage: View {
    let url: URL?
    /// Allows for the parent view to load the loaded image in its own property that
    /// can then be used for other things.
    @Binding var loadedImage: Image?
    
    init(url: URL?, loadedImage: Binding<Image?>) {
        self.url = url
        _loadedImage = Binding(projectedValue: loadedImage)
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .onAppear {
                        self.loadedImage = image
                    }
                
            case .failure:
                NoImageView()
                
            @unknown default:
                NoImageView()
            }
        }
        .frame(width: 135, height: 135)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(.white, lineWidth: 3)
        }
    }
}

struct ProfileAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileAsyncImage(url: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/the-same-page-9c69e.appspot.com/o/images%2FCB5B7C63-3ACC-4CE6-83A1-AD96D97AB7AB.jpg?alt=media&token=4e0ccba7-6643-4f73-9391-43ee40aaca77"), loadedImage: .constant(nil))
    }
}
