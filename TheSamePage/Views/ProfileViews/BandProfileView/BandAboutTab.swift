//
//  BandAboutTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct BandAboutTab: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    var body: some View {
        if let band = viewModel.band,
           let bandBio = band.bio {
            HStack {
                Text(bandBio)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
}

struct BandAboutTab_Previews: PreviewProvider {
    static var previews: some View {
        BandAboutTab(viewModel: BandProfileViewModel(band: Band.example))
    }
}
