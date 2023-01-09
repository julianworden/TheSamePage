//
//  AddEditShowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import Contacts
import FirebaseFirestore
import MapKit
import UIKit.UIImage

@MainActor
final class AddEditShowViewModel: ObservableObject {
    var showToEdit: Show?
    
    @Published var showName = ""
    @Published var showDescription = ""
    @Published var showVenue = ""
    @Published var showHostName = ""
    @Published var showGenre = Genre.rock
    @Published var showMaxNumberOfBands = 1
    @Published var showDate = Date.now
    
    // Make it so that shows are not private by default
    @Published var addressIsPrivate = false
    @Published var showAddress: String?
    var showCity: String?
    var showState: String?
    var showLatitude: Double = 0
    var showLongitude: Double = 0
    var showTypesenseCoordinates = [Double]()
    var addressSearch: MKLocalSearch?
    
    var bandIds = [String]()
    var participantUids = [String]()
    
    @Published var showIsFree = false
    @Published var ticketPrice = ""
    @Published var ticketSalesAreRequired = false
    @Published var minimumRequiredTicketsSold = ""
    @Published var showIs21Plus = false
    @Published var showHasBar = false
    @Published var showHasFood = false
    
    @Published var imagePickerIsShowing = false
    @Published var bandSearchSheetIsShowing = false
    @Published var showImage: UIImage?
    @Published var createShowButtonIsDisabled = false
    @Published var errorAlertIsShowing = false
    @Published var showCreatedSuccessfully = false
    
    var errorAlertText = ""
    
    var viewState = ViewState.dataLoaded {
        didSet {
            switch viewState {
            case .performingWork:
                createShowButtonIsDisabled = true
            case .workCompleted:
                showCreatedSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                createShowButtonIsDisabled = false
            default:
                print("Unknown ViewState assigned to AddEditShowViewModel.")
            }
        }
    }
    
    var publiclyVisibleAddressExplanation: String {
        if addressIsPrivate {
            return "Anybody can see this show's address"
        } else {
            return "Anybody can see this show's city and state, but only this show's participants can see the full address"
        }
    }
    
    var formIsComplete: Bool {
        if showIsFree {
            return !showName.isReallyEmpty &&
            !showVenue.isReallyEmpty &&
            !showHostName.isReallyEmpty &&
            showAddress != nil
        } else {
            return !showName.isReallyEmpty &&
            !showVenue.isReallyEmpty &&
            !showHostName.isReallyEmpty &&
            !ticketPrice.isReallyEmpty &&
            showAddress != nil
        }
    }
    
    init(showToEdit: Show? = nil) {
        if let showToEdit {
            self.showToEdit = showToEdit
            self.showName = showToEdit.name
            self.showDescription = showToEdit.description ?? ""
            self.showVenue = showToEdit.venue
            self.showHostName = showToEdit.host
            self.showGenre = Genre(rawValue: showToEdit.genre) ?? Genre.rock
            self.showMaxNumberOfBands = showToEdit.maxNumberOfBands
            self.showDate = Date(timeIntervalSince1970: showToEdit.date)
            self.bandIds = showToEdit.bandIds
            self.participantUids = showToEdit.participantUids
            self.addressIsPrivate = showToEdit.addressIsPrivate
            self.showIsFree = showToEdit.isFree
            self.showAddress = showToEdit.address
            self.showCity = showToEdit.city
            self.showState = showToEdit.state
            self.showLatitude = showToEdit.latitude
            self.showLongitude = showToEdit.longitude
            self.showTypesenseCoordinates = showToEdit.typesenseCoordinates
            self.ticketPrice = String(showToEdit.ticketPrice ?? 0)
            self.ticketSalesAreRequired = showToEdit.ticketSalesAreRequired
            self.minimumRequiredTicketsSold = String(showToEdit.minimumRequiredTicketsSold ?? 0)
            self.showIs21Plus = showToEdit.is21Plus
            self.showHasBar = showToEdit.hasBar
            self.showHasFood = showToEdit.hasFood
        }
    }
    
    func addShowAddressObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showAddressSelectedNotificationReceived(notification:)),
            name: .showAddressSelected,
            object: nil
        )
    }
    
    @objc func showAddressSelectedNotificationReceived(notification: NSNotification) {
        if let showPlacemark = notification.userInfo?[NotificationConstants.showPlacemark] as? CLPlacemark {
            if let showLatitude = showPlacemark.location?.coordinate.latitude,
               let showLongitude = showPlacemark.location?.coordinate.longitude {
                self.showLatitude = showLatitude
                self.showLongitude = showLongitude
                self.showTypesenseCoordinates = [showLatitude, showLongitude]
            }

            showAddress = showPlacemark.formattedAddress
            showCity = showPlacemark.postalAddress?.city
            showState = showPlacemark.postalAddress?.state
        }
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
    
    func updateCreateShowButtonTapped(withImage image: UIImage? = nil) async -> String? {
        do {
            var showId: String?
            viewState = .performingWork
            showToEdit == nil ? showId = try await createShow(withImage: image) : try await updateShow()
            viewState = .workCompleted
            return showId
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
    
    func createShow(withImage image: UIImage? = nil) async throws -> String {
        guard formIsComplete else { throw LogicError.incompleteForm }
        
        let newShow = Show(
            id: "",
            name: showName,
            description: showDescription.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : showDescription,
            host: showHostName,
            hostUid: AuthController.getLoggedInUid(),
            bandIds: bandIds,
            participantUids: participantUids,
            venue: showVenue,
            date: showDate.timeIntervalSince1970,
            isFree: showIsFree,
            ticketPrice: Double(ticketPrice),
            ticketSalesAreRequired: ticketSalesAreRequired,
            minimumRequiredTicketsSold: Int(minimumRequiredTicketsSold),
            addressIsPrivate: addressIsPrivate,
            address: showAddress ?? "Unknown Address",
            city: showCity ?? "Unknown City",
            state: showState ?? "Unknown State",
            latitude: showLatitude,
            longitude: showLongitude,
            typesenseCoordinates: showTypesenseCoordinates,
            imageUrl: image == nil ? nil : try await DatabaseService.shared.uploadImage(image: image!),
            hasFood: showHasFood,
            hasBar: showHasBar,
            is21Plus: showIs21Plus,
            genre: showGenre.rawValue,
            maxNumberOfBands: showMaxNumberOfBands
        )
        
        return try await DatabaseService.shared.createShow(show: newShow)
    }
    
    func updateShow() async throws {
        guard formIsComplete else { throw LogicError.incompleteForm }
        
        // Force unwraps are safe for showToEdit because this method is only called when showToEdit != nil
        let updatedShow = Show(
            id: showToEdit!.id,
            name: showName,
            description: showDescription.isReallyEmpty ? nil : showDescription,
            host: showHostName,
            hostUid: AuthController.getLoggedInUid(),
            bandIds: bandIds,
            participantUids: participantUids,
            venue: showVenue,
            date: showDate.timeIntervalSince1970,
            isFree: showIsFree,
            ticketPrice: Double(ticketPrice),
            ticketSalesAreRequired: ticketSalesAreRequired,
            minimumRequiredTicketsSold: Int(minimumRequiredTicketsSold),
            addressIsPrivate: addressIsPrivate,
            address: showAddress ?? "Unknown Address",
            city: showCity ?? "Unknown City",
            state: showState ?? "Unknown State",
            latitude: showLatitude,
            longitude: showLongitude,
            typesenseCoordinates: showTypesenseCoordinates,
            hasFood: showHasFood,
            hasBar: showHasBar,
            is21Plus: showIs21Plus,
            genre: showGenre.rawValue,
            maxNumberOfBands: showMaxNumberOfBands
        )
        
        try await DatabaseService.shared.updateShow(show: updatedShow)
    }
}

