//
//  ShowLineupRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/26/22.
//

import SwiftUI

struct ShowLineupRow: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    let index: Int
    
    var body: some View {
        let showParticipant = viewModel.showLineup[index]
        
        VStack(spacing: 10) {
            HStack {
                Image("band")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text(showParticipant.name)
                
                Spacer()
                
                Image(systemName: "chevron.right")
//                    .padding(.trailing, 7)
            }
            
            Divider()
        }
    }
}

struct ShowLineupRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupRow(viewModel: ShowDetailsViewModel(show: Show.example), index: 0)
    }
}
