//
//  HomeShowCard.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import SwiftUI

struct HomeShowCard: View {
    @StateObject var viewModel: HomeShowCardViewModel
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: HomeShowCardViewModel(show: show))
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            HStack(spacing: 13) {
                Image(systemName: "photo.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 126, height: 126)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.show.name)
                        .font(.title3.bold())
                    
                    Text(viewModel.show.venue)
                        .font(.caption)
                    
                    if let showDescription = viewModel.show.description {
                        Text(showDescription)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                                    
                    HStack {
                        Image(systemName: "21.circle")
                        
                        Image(systemName: "fork.knife.circle")
                        
                        Spacer()
                        
                        // TODO: Use a custom Date .formatted() extension for this instead
                        Text(TextUtility.formatDate(unixDate: viewModel.show.date))
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 175)
        .padding(.horizontal)
    }
}

struct HomeShowCard_Previews: PreviewProvider {
    static var previews: some View {
        HomeShowCard(show: Show.example)
            .previewLayout(.fixed(width: 390, height: 175))
    }
}
