//
//  ShowLineupRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import SwiftUI

struct ShowLineupRow: View {
    @StateObject var viewModel: ShowLineupRowViewModel
    
    init(showParticipant: ShowParticipant, rowIndex: Int, lineupCount: Int) {
        _viewModel = StateObject(wrappedValue: ShowLineupRowViewModel(showParticipant: showParticipant, rowIndex: rowIndex, lineupCount: lineupCount))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("band")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding(.leading, 10)
                
                Text(viewModel.showParticipantName)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .padding(.trailing)
            }
            .frame(height: 50)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            
            if viewModel.rowIndex != viewModel.lineupCount - 1 {
                Divider()
            }
        }
    }
}

struct ShowLineupRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupRow(showParticipant: ShowParticipant.example, rowIndex: 0, lineupCount: 1)
            .previewLayout(.fixed(width: 390, height: 50))
    }
}
