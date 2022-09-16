//
//  HomeShowCard.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

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
                .frame(height: 175)
            
            HStack(spacing: 13) {
                Image(systemName: "photo.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 126, height: 126)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.show.name)
                        .font(.title3.bold())
                    
                    Text(viewModel.show.venueName)
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
                        
                        Text(viewModel.show.time.start.formatted(date: .numeric, time: .omitted))
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct HomeShowCard_Previews: PreviewProvider {
    static var previews: some View {
        HomeShowCard(show: Show.example)
            .previewLayout(.fixed(width: 390, height: 175))
    }
}
