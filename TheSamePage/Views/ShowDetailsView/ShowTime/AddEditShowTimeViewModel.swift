//
//  AddEditShowTimeViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import Foundation

class AddEditShowTimeViewModel: ObservableObject {
    @Published var showTime = Date()
    
    let show: Show
    var showTimeToEdit: Date?
    var showTimeType: ShowTimeType
    
    init(show: Show, showTimeType: ShowTimeType, showTimeToEdit: Date?) {
        self.show = show
        self.showTimeType = showTimeType
        
        if let showTimeToEdit {
            self.showTime = showTimeToEdit
        }
    }
    
    func addShowTime(ofType showTimeType: ShowTimeType) async throws {
        let showDate = Date(timeIntervalSince1970: show.date)
        var dateComponents = DateComponents()
        dateComponents.year = Calendar.current.dateComponents([.year], from: showDate).year
        dateComponents.month = Calendar.current.dateComponents([.month], from: showDate).month
        dateComponents.day = Calendar.current.dateComponents([.day], from: showDate).day
        dateComponents.hour = Calendar.current.dateComponents([.hour], from: showTime).hour
        dateComponents.minute = Calendar.current.dateComponents([.minute], from: showTime).minute
        
        if let fullTimeWithDate = Calendar.current.date(from: dateComponents) {
            try await DatabaseService.shared.addTimeToShow(addTime: fullTimeWithDate, ofType: showTimeType, forShow: show)
        }
    }
}
