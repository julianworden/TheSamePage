////
////  AddShowTimeButtons.swift
////  TheSamePage
////
////  Created by Julian Worden on 10/14/22.
////
//
//import SwiftUI
//
//struct AddShowTimeButtons: View {
//    @ObservedObject var viewModel: ShowDetailsViewModel
//        
//    var body: some View {
//        let show = viewModel.show
//        
//        HStack {
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    if show.doorsTime == nil {
//                        Button("Add Doors Time") {
//                            selectedShowTimeType = .doors
//                        }
//                    }
//                    
//                    if show.endTime == nil {
//                        Button("Add End Time") {
//                            selectedShowTimeType = .end
//                        }
//                    }
//                    
//                    if show.loadInTime == nil {
//                        Button("Add Load In Time") {
//                            selectedShowTimeType = .loadIn
//                        }
//                    }
//                    
//                    if show.musicStartTime == nil {
//                        Button("Add Music Start Time") {
//                            selectedShowTimeType = .musicStart
//                        }
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//            }
//            
//            if show.hasTime {
//                EditButton()
//            }
//        }
//    }
//}
//
//struct AddShowTimeButtons_Previews: PreviewProvider {
//    static var previews: some View {
//        AddShowTimeButtons(viewModel: ShowDetailsViewModel(show: Show.example), selectedShowTimeType: .constant(.musicStart))
//    }
//}
