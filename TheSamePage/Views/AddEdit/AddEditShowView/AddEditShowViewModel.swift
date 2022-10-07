//
//  AddEditShowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseFirestore
import Foundation
import UIKit.UIImage

class AddEditShowViewModel: ObservableObject {
    var showToEdit: Show?
    let viewTitleText: String
    
    @Published var showName = ""
    @Published var showDescription = ""
    @Published var showVenue = ""
    @Published var showHostName = ""
    @Published var showGenre = Genre.rock
    @Published var showMaxNumberOfBands = 1
    @Published var showDate = Date()
    @Published var showDateIsKnown = false
    @Published var showLoadInTime = Date()
    @Published var showFirstSetTime = Date()
    @Published var showDoorsTime = Date()
    @Published var showEndTime = Date()
    @Published var showTimesAreKnown = false
    @Published var showIs21Plus = false
    @Published var showHasBar = false
    @Published var showHasFood = false
    
    init(viewTitleText: String, showToEdit: Show?) {
        self.showToEdit = showToEdit
        self.viewTitleText = viewTitleText
    }
    
    func incrementMaxNumberOfBands() {
        if showMaxNumberOfBands < 101 {
            showMaxNumberOfBands += 1
        }
    }
    
    func decrementMaxNumberOfBands() {
        if showMaxNumberOfBands > 1 {
            showMaxNumberOfBands -= 1
        }
    }
    
    func createShow(withImage image: UIImage?) async throws {
        var newShow: Show
        var showTime: Time?
        
        if showTimesAreKnown {
            showTime = Time(
                loadIn: Timestamp(date: showLoadInTime),
                doors: Timestamp(date: showDoorsTime),
                firstSetStart: Timestamp(date: showFirstSetTime),
                end: Timestamp(date: showEndTime)
            )
        }
        
        if let image {
            let imageUrl = try await DatabaseService.shared.uploadImage(image: image)
            newShow = Show(
                name: showName,
                description: showDescription,
                host: showHostName,
                hostUid: AuthController.getLoggedInUid(),
                venue: showVenue,
                date: showDate.timeIntervalSince1970,
                time: showTime,
                ticketPrice: nil,
                imageUrl: imageUrl,
//                location: Location.example,
                backline: nil,
                hasFood: showHasFood,
                hasBar: showHasBar,
                is21Plus: showIs21Plus,
                genre: showGenre.rawValue,
                maxNumberOfBands: showMaxNumberOfBands,
                bands: nil
            )
        } else {
            newShow = Show(
                name: showName,
                description: showDescription,
                host: showHostName,
                hostUid: AuthController.getLoggedInUid(),
                venue: showVenue,
                date: showDate.timeIntervalSince1970,
                time: showTime,
                ticketPrice: nil,
                imageUrl: nil,
//                location: Location.example,
                backline: nil,
                hasFood: showHasFood,
                hasBar: showHasBar,
                is21Plus: showIs21Plus,
                genre: showGenre.rawValue,
                maxNumberOfBands: showMaxNumberOfBands,
                bands: nil
            )
        }
        
        try await DatabaseService.shared.createShow(show: newShow)
    }
}
