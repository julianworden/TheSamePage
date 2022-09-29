//
//  BandMemberRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import SwiftUI

struct BandMemberCard: View {
    @StateObject var viewModel: BandMemberCardViewModel
    
    init(bandMember: BandMember) {
        _viewModel = StateObject(wrappedValue: BandMemberCardViewModel(bandMember: bandMember))
    }
    
    // TODO: Make the name say "You" for the logged in user's card if they're a member of the band you're viewing
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.memberName)
                    
                    Text(viewModel.memberRole)
                        .font(.caption)
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "person")
            }
            .padding(.horizontal)
        }
        .frame(width: 149, height: 70)
//        .padding(.horizontal)
    }
}

struct BandMemberRow_Previews: PreviewProvider {
    static var previews: some View {
        BandMemberCard(bandMember: BandMember.example)
    }
}
