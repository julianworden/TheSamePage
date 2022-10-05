//
//  SearchResultRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import SwiftUI

struct SearchResultRow: View {
    @StateObject var viewModel: SearchResultRowViewModel
    
    init(band: Band?, user: User?, show: Show?) {
        _viewModel = StateObject(wrappedValue: SearchResultRowViewModel(band: band, user: user, show: show))
    }
    
    var body: some View {
        HStack {
            if let band = viewModel.band {
                Image("band")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding(.leading, 10)
                
                VStack(alignment: .leading) {
                    Text(band.name)
                    
                    Text("\(band.city), \(band.state)")
                        .font(.caption)
                }
            }
            
            if let user = viewModel.user {
                Image("user")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                
                VStack(alignment: .leading) {
                    Text(user.username)
                    
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.caption)
                }
            }
            
            if let show = viewModel.show {
                Image("stage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding(.leading, 10)
                
                VStack(alignment: .leading) {
                    Text(show.name)
                    
                    Text(show.location.address)
                        .font(.caption)
                }
            }
            
            Spacer()
        }
    }
}

struct SearchResultRow_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultRow(band: nil, user: nil, show: Show.example)
            .previewLayout(.fixed(width: 390, height: 44))
    }
}
