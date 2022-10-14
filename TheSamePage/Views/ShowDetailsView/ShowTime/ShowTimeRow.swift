//
//  ShowTimeRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/13/22.
//

import SwiftUI

struct ShowTimeRow: View {
    @Environment(\.editMode) var editMode
    
    @ObservedObject var viewModel: ShowTimeTabViewModel
    
    let showTimeType: ShowTimeType
    
    var body: some View {
        ZStack {
            SmallListRow(
                title: (viewModel.getRowText(forShowTimeType: showTimeType)) ?? "Show Time",
                subtitle: nil,
                iconName: showTimeType.rowIconName,
                displayChevron: false)
            
            if editMode?.wrappedValue == .active {
                HStack {
                    Spacer()
                    
                    Button(role: .destructive) {
                        viewModel.removeShowTimeFromShow(showTimeType: showTimeType)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                .padding(.trailing)
            }
        }
    }
}

struct ShowTimeRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeRow(viewModel: ShowTimeTabViewModel(show: Show.example), showTimeType: .musicStart)
    }
}
