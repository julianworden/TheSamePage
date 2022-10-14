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
    @State private var showTimeToEdit: Date?
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowTimeTabViewModel(show: show))
    }
    
    var body: some View {
        VStack {
            HStack {
                // TODO: Make this scrollview a separate view
                ScrollView(.horizontal, showsIndicators: false) {
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
                    .buttonStyle(.borderedProminent)
                }
                
                EditButton()
            }
            .padding(.horizontal)
            
            ShowTimeList(viewModel: viewModel)
                .padding(.horizontal)
        }
        .onAppear {
            do {
                try viewModel.addShowTimesListener()
            } catch {
                print(error)
            }
        }
        .onDisappear {
            viewModel.removeShowTimesListener()
        }
        .sheet(item: $selectedShowTimeType) { showTimeType in
            NavigationView {
                switch showTimeType {
                case .loadIn:
                    AddShowTimeView(show: viewModel.show, showTimeType: showTimeType)
                case .musicStart:
                    AddShowTimeView(show: viewModel.show, showTimeType: showTimeType)
                case .end:
                    AddShowTimeView(show: viewModel.show, showTimeType: showTimeType)
                case .doors:
                    AddShowTimeView(show: viewModel.show, showTimeType: showTimeType)
                }
            }
        }
    }
}

struct ShowTimeTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowTimeTab(show: Show.example)
    }
}
