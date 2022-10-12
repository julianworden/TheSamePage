//
//  LargeListRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import SwiftUI

struct LargeListRow: View {
    @StateObject var viewModel: LargeListRowViewModel
    
    init(show: Show?, joinedShow: JoinedShow?) {
        _viewModel = StateObject(wrappedValue: LargeListRowViewModel(show: show, joinedShow: joinedShow))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.showName)
                        .font(.title3.bold())
                    
                    Text(viewModel.showVenue)
                    
                    Text(viewModel.showDate)
                    
                    Text(viewModel.showDescription)
                        .lineLimit(2)
                        .font(.caption)
                    
                    HStack {
                        if viewModel.showHasBar {
                            Image(systemName: "wineglass")
                        }
                        
                        if viewModel.showHasFood {
                            Image(systemName: "fork.knife")
                        }
                        
                        if viewModel.showIs21Plus {
                            Image(systemName: "21.circle")
                        }
                    }
                    .imageScale(.small)
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            
            Divider()
        }
        .background(.white)
    }
}

struct ShowCard_Previews: PreviewProvider {
    static var previews: some View {
        LargeListRow(show: Show.example, joinedShow: nil)
    }
}
