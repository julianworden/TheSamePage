//
//  ShowTimeRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/13/22.
//

import SwiftUI

struct ShowTimeRow: View {
    @Environment(\.editMode) var editMode
    
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    let showTimeType: ShowTimeType
    
    var body: some View {
        VStack {
            HStack {
                Image(showTimeType.rowIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text(viewModel.getShowTimeRowText(forShowTimeType: showTimeType))
                
                Spacer()
                
                if editMode?.wrappedValue == .active {
                    Button(role: .destructive) {
                        viewModel.removeShowTimeFromShow(showTimeType: showTimeType)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .padding(.trailing)
                }
            }
            
            Divider()
        }
    }
}

struct ShowTimeRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeRow(viewModel: ShowDetailsViewModel(show: Show.example), showTimeType: .doors)
    }
}
