//
//  AddShowTimeViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import Foundation

@MainActor
final class AddShowTimeViewModel: ObservableObject {
    @Published var showTime = Date()
    @Published var errorMessageIsShowing = false
    @Published var errorMessageText = ""
    
    let show: Show
    var showTimeType: ShowTimeType
    
    init(show: Show, showTimeType: ShowTimeType) {
        self.show = show
        self.showTimeType = showTimeType
    }
    
    func addShowTime(ofType showTimeType: ShowTimeType) {
        Task {
            let showDate = Date(timeIntervalSince1970: show.date)
            var dateComponents = DateComponents()
            dateComponents.year = Calendar.current.dateComponents([.year], from: showDate).year
            dateComponents.month = Calendar.current.dateComponents([.month], from: showDate).month
            dateComponents.day = Calendar.current.dateComponents([.day], from: showDate).day
            dateComponents.hour = Calendar.current.dateComponents([.hour], from: showTime).hour
            dateComponents.minute = Calendar.current.dateComponents([.minute], from: showTime).minute
            
            
            if let fullTimeWithDate = Calendar.current.date(from: dateComponents) {
                do {
                    try await DatabaseService.shared.addTimeToShow(addTime: fullTimeWithDate, ofType: showTimeType, forShow: show)
                } catch {
                    errorMessageIsShowing = true
                    errorMessageText = error.localizedDescription
                }
            }
        }
    }
}
