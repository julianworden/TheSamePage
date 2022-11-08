//
//  UserBandList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct UserBandList: View {
    @StateObject var viewModel: UserBandListViewModel
    
    let columns = [GridItem(.fixed(149), spacing: 15), GridItem(.fixed(149), spacing: 15)]
    
    init(bands: [Band]) {
        _viewModel = StateObject(wrappedValue: UserBandListViewModel(bands: bands))
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(viewModel.bands) { band in
                NavigationLink {
                    BandProfileView(band: band)
                } label: {
                    UserProfileBandCard(band: band)
                }
                .tint(.black)
            }
            .animation(.easeInOut, value: viewModel.bands)
        }
    }
}

struct UserBandList_Previews: PreviewProvider {
    static var previews: some View {
        UserBandList(bands: [Band.example])
    }
}
