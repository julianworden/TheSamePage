//
//  ShowDetailsTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowDetailsTab: View {
    @StateObject var viewModel: ShowDetailsTabViewModel
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowDetailsTabViewModel(show: show))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                if let showDescription = viewModel.showDescription {
                    Text(showDescription)
                        .padding(.bottom, 5)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            ShowDetailsList(viewModel: viewModel)
        }
        .padding(.top, 2)
        .onDisappear {
            viewModel.removeShowListener()
        }
    }
}

struct ShowDetailsTab_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ShowDetailsTab(show: Show.example)
        }
    }
}
