//
//  MyShowsShowCard.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import SwiftUI

struct MyShowsShowCard: View {
    @StateObject var viewModel: MyShowsShowCardViewModel
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: MyShowsShowCardViewModel(show: show))
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            VStack(alignment: .center, spacing: 9) {
                Text(viewModel.show.name)
                    .font(.title3.bold())
                
                Text(viewModel.show.venue)
                    .font(.caption)
                
                if let showDescription = viewModel.show.description {
                    Text(showDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(4)
                }
                
                HStack {
                    Image(systemName: "21.circle")
                    
                    Image(systemName: "fork.knife.circle")
                    
                    Text(TextUtility.formatDate(date: viewModel.show.date.dateValue()))
                    
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .frame(width: 191, height: 222)
        .padding(.vertical)
    }
}

struct MyShowsShowCard_Previews: PreviewProvider {
    static var previews: some View {
        MyShowsShowCard(show: Show.example)
    }
}
