//
//  BandMemberRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import SwiftUI

struct BandMemberRow: View {
    @StateObject var viewModel: BandMemberRowViewModel
    
    let index: Int
    let membersCount: Int
    
    init(bandMember: BandMember, index: Int, membersCount: Int) {
        _viewModel = StateObject(wrappedValue: BandMemberRowViewModel(bandMember: bandMember))
        self.index = index
        self.membersCount = membersCount
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "person")
                    .padding(.leading)
                
                VStack(alignment: .leading) {
                    Text(viewModel.memberUid == AuthController.getLoggedInUid() ? "You" : viewModel.memberName)
                    
                    Text(viewModel.memberRole)
                        .font(.caption)
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .padding(.trailing)
            }
            .frame(height: 50)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            
            if index != membersCount - 1 {
                Divider()
            }
        }
    }
}

struct BandMemberRow_Previews: PreviewProvider {
    static var previews: some View {
        BandMemberRow(bandMember: BandMember.example, index: 0, membersCount: 0)
    }
}
