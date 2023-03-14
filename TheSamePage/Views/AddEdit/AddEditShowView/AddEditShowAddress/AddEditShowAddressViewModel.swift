//
//  AddEditShowAddressViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/22/22.
//

import Foundation
import MapKit

@MainActor
final class AddEditShowAddressViewModel: ObservableObject {
    @Published var showAddressSelected = false
    @Published var isSearching = false
    @Published var queryText = ""
    @Published var addressSearchResults = [CLPlacemark]()
    @Published var showAddress: String?
    
    var showToEdit: Show?
    var addressSearch: MKLocalSearch?
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    init(showToEdit: Show?) {
        self.showToEdit = showToEdit
        
        if let showToEdit {
            self.showAddress = showToEdit.address
        }
    }
    
    var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                print("Unknown ViewState assigned to AddEditShowViewModel.")
            }
        }
    }
    
    func search(withText text: String) async {
        let searchRequest = MKLocalSearch.Request()
        if let userRegion = LocationController.shared.userRegion {
            searchRequest.region = userRegion
        }
        
        searchRequest.naturalLanguageQuery = text
        
        addressSearch = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await addressSearch!.start()
            
            if response.mapItems.isEmpty {
                addressSearchResults = [CLPlacemark]()
            }
            
            addressSearchResults = response.mapItems.map { $0.placemark }
            addressSearch?.cancel()
        } catch {
            // This error doesn't prevent the search from working and it comes up often.
            // Ignoring to keep experience smooth for user, there are other MK errors
            // that are still thrown if too many requests are submitted in 60 seconds.
            // Those will be allowed.
            if !error.localizedDescription.contains("MKErrorDomain error 4") && !error.localizedDescription.contains("MKErrorDomain error 3") {
                viewState = .error(message: "Search failed, please try again. System error: \(error.localizedDescription)")
            }
        }
    }
    
    func isSearchingChanged(to isSearching: Bool) {
        if !isSearching {
            queryText = ""
            addressSearchResults = [CLPlacemark]()
        }
    }
    
    func setShowLocationInfo(with placemark: CLPlacemark) {
        showAddress = placemark.formattedAddress
        
        showAddressSelected = true
        queryText = ""
        
        NotificationCenter.default.post(
            name: .showAddressSelected,
            object: nil,
            userInfo: [NotificationConstants.showPlacemark: placemark]
        )
    }
}
