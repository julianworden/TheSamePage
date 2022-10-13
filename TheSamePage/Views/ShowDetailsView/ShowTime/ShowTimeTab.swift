//
//  ShowTimeTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

struct ShowTimeTab: View {
    @StateObject var viewModel: ShowTimeTabViewModel
    
    @State private var selectedShowTimeType: ShowTimeType?
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowTimeTabViewModel(show: show))
    }
    
    var body: some View {
        VStack {
            HStack {
                if viewModel.showDoorsTime == nil {
                    Button("Add Doors Time") {
                        selectedShowTimeType = .doors
                    }
                }
                
                if viewModel.showEndTime == nil {
                    Button("Add End Time") {
                        selectedShowTimeType = .end
                    }
                }
                
                if viewModel.showLoadInTime == nil {
                    Button("Add Load In Time") {
                        selectedShowTimeType = .loadIn
                    }
                }
                
                if viewModel.showMusicStartTime == nil {
                    Button("Add Music Start Time") {
                        selectedShowTimeType = .musicStart
                    }
                }
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            
            ShowTimeList(viewModel: viewModel)
                .padding(.horizontal)
        }
        .sheet(item: $selectedShowTimeType) { showTimeType in
            NavigationView {
                AddEditShowTimeView(show: viewModel.show, showTimeType: showTimeType, showTimeToEdit: nil)
            }
        }
    }
}

struct ShowTimeTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeTab(show: Show.example)
    }
}
