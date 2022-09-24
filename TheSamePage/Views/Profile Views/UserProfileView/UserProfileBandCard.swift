//
//  ProfileViewBandCard.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/17/22.
//

import SwiftUI

struct UserProfileBandCard: View {
    @StateObject var viewModel: UserProfileBandCardViewModel
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: UserProfileBandCardViewModel(band: band))
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            VStack(alignment: .center, spacing: 2) {
                Text(viewModel.band.name)
                    .font(.body.bold())
                
                Text(viewModel.band.genre)
                    .font(.caption)
                Text("\(viewModel.band.city), \(viewModel.band.state)")
                    .font(.caption)
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: 149, height: 130)
    }
}

struct ProfileViewBandCard_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileBandCard(band: Band.example)
    }
}
