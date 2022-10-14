//
//  AddShowTimeButtons.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/14/22.
//

import SwiftUI

struct AddShowTimeButtons: View {
    @ObservedObject var viewModel: ShowTimeTabViewModel
    
    @Binding var selectedShowTimeType: ShowTimeType?
    
    var body: some View {
        HStack {
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
    }
}

struct AddShowTimeButtons_Previews: PreviewProvider {
    static var previews: some View {
        AddShowTimeButtons(viewModel: ShowTimeTabViewModel(show: Show.example), selectedShowTimeType: .constant(.musicStart))
    }
}
