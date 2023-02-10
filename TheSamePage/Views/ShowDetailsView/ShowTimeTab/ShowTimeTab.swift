//
//  ShowTimeTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

struct ShowTimeTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    @State private var showTimeToEdit: Date?
    
    var body: some View {        
        VStack {
            ShowTimeList(viewModel: viewModel)
        }
        .padding(.horizontal)
    }
}

struct ShowTimeTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
