//
//  BandLinkCard.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/30/22.
//

import SwiftUI

struct BandLinkCard: View {
    @StateObject var viewModel: BandLinkCardViewModel
    
    init(link: Link) {
        _viewModel = StateObject(wrappedValue: BandLinkCardViewModel(link: link))
    }
    
    var body: some View {
        Button {
            viewModel.openLink()
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                
                Image(viewModel.iconName)
            }
            .frame(width: 70, height: 70)
        }
    }
}

struct BandLinkCard_Previews: PreviewProvider {
    static var previews: some View {
        BandLinkCard(link: Link.example)
    }
}
