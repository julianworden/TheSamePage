//
//  ProfileViewBandCard.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/17/22.
//

import SwiftUI

struct ProfileBandCard: View {
    @StateObject var viewModel: ProfileBandCardViewModel
    
    @Binding var streamingActionSheetIsShowing: Bool
    
    init(band: Band, streamingActionSheetIsShowing: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: ProfileBandCardViewModel(band: band))
        _streamingActionSheetIsShowing = Binding(projectedValue: streamingActionSheetIsShowing)
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
                
                Button {
                    streamingActionSheetIsShowing = true
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .padding(.top, 2)
                }
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: 149, height: 130)
    }
}

struct ProfileViewBandCard_Previews: PreviewProvider {
    static var previews: some View {
        ProfileBandCard(band: Band.example, streamingActionSheetIsShowing: .constant(false))
    }
}
