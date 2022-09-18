//
//  AddEditShowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseFirestore
import Foundation

class AddEditShowViewModel: ObservableObject {
    var showToEdit: Show?
    
    @Published var showName = ""
    @Published var showDescription = ""
    @Published var showVenue = ""
    @Published var showDate = Date()
    @Published var showLoadInTime = Date()
    @Published var showFirstSetTime = Date()
    @Published var showDoorsTime = Date()
    @Published var showEndTime = Date()
    @Published var showIs21Plus = false
    @Published var showHasBar = false
    @Published var showHasFood = false
    
    init(showToEdit: Show? = nil) {
        self.showToEdit = showToEdit
    }
    
    func createShow() throws {
        let showTime = Time(
            loadIn: Timestamp(date: showLoadInTime),
            doors: Timestamp(date: showDoorsTime),
            firstSetStart: Timestamp(date: showFirstSetTime),
            end: Timestamp(date: showEndTime)
        )
        let newShow = Show(
            name: showName,
            description: showDescription,
            host: "DAA Entertainment",
            hostUid: AuthController.getLoggedInUid(),
            participantUids: [],
            venue: showVenue,
            date: Timestamp(date: showDate),
            time: showTime,
            ticketPrice: nil,
            imageUrl: nil,
            location: Location.example,
            backline: nil,
            hasFood: showHasFood,
            hasBar: showHasBar,
            is21Plus: showIs21Plus,
            genre: nil,
            bands: nil
        )
        
        try DatabaseService.shared.createShow(show: newShow)
    }
}
