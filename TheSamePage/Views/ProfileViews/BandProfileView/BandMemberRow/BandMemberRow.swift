//
//  BandMemberRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import SwiftUI

struct BandMemberRow: View {
    @StateObject var viewModel: BandMemberRowViewModel
    
    init(bandMember: BandMember, index: Int, membersCount: Int, bandMemberIsLoggedInUser: Bool) {
        _viewModel = StateObject(wrappedValue: BandMemberRowViewModel(bandMember: bandMember, index: index, membersCount: membersCount, bandMemberIsLoggedInUser: bandMemberIsLoggedInUser))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(viewModel.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding(.leading, 10)
                
                VStack(alignment: .leading) {
                    Text(viewModel.memberUid == AuthController.getLoggedInUid() ? "You" : viewModel.memberName)
                    
                    Text(viewModel.memberRole)
                        .font(.caption)
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                if !viewModel.bandMemberIsLoggedInUser {
                    Image(systemName: "chevron.right")
                        .padding(.trailing)
                }
            }
            .frame(height: 50)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            
            if viewModel.index != viewModel.membersCount - 1 {
                Divider()
            }
        }
    }
}

struct BandMemberRow_Previews: PreviewProvider {
    static var previews: some View {
        BandMemberRow(bandMember: BandMember.example, index: 0, membersCount: 1, bandMemberIsLoggedInUser: false)
    }
}
