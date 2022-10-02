//
//  BandProfileHeader.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandProfileHeader: View {
    @StateObject var viewModel: BandProfileHeaderViewModel
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: BandProfileHeaderViewModel(band: band))
    }
    
    var body: some View {
        if viewModel.bandImageUrl != nil {
            ProfileAsyncImage(url: URL(string: viewModel.bandImageUrl!))
        } else {
            NoImageView()
                .padding(.horizontal)
        }
        
        VStack {
            Text(viewModel.bandName)
                .font(.title.bold())
            
            Text("\(viewModel.bandGenre) from \(viewModel.bandCity), \(viewModel.bandState)")
        }
        .padding(.top, 2)
        
        if let bandBio = viewModel.bandBio {
            Text(bandBio)
                .padding(.horizontal)
        }
    }
}

struct BandProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileHeader(band: Band.example)
    }
}
