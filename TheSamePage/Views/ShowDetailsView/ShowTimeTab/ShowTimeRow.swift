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
        ZStack {
            HStack {
                ListRowElements(
                    title: viewModel.getShowTimeRowText(forShowTimeType: showTimeType),
                    iconName: showTimeType.rowIconName
                )
                
                Spacer()

                // TODO: Make the trash cans always visible for existing times. For non-existent times, show an Unknown title with a plus button that's always visible
                if editMode?.wrappedValue == .active {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.removeShowTimeFromShow(showTimeType: showTimeType)
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .padding(.trailing)
                }
            }
        }
    }
}

struct ShowTimeRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeRow(viewModel: ShowDetailsViewModel(show: Show.example), showTimeType: .doors)
    }
}
