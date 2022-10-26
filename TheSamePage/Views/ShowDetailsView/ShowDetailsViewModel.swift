//
//  ShowDetailsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import FirebaseFirestore
import Foundation
import MapKit

class ShowDetailsViewModel: ObservableObject {
    @Published var show: Show
    @Published var showLineup = [ShowParticipant]()
    @Published var selectedTab = SelectedShowDetailsTab.details
    @Published var state = ViewState.dataLoading
    
    let db = Firestore.firestore()
    var showListener: ListenerRegistration?
    
    var showSlotsRemainingMessage: String {
        let slotsRemainingCount = show.maxNumberOfBands - showLineup.count
        
        if slotsRemainingCount == 1 {
            return "\(slotsRemainingCount) slot remaining"
        } else {
            return "\(slotsRemainingCount) slots remaining"
        }
    }
    
    var mapAnnotations: [CustomMapAnnotation] {
        let venue = CustomMapAnnotation(coordinates: show.coordinates)
        return [venue]
    }
    
    init(show: Show) {
        self.show = show
        
        Task {
            do {
                try await getShowLineup()
            } catch {
                state = .error(message: error.localizedDescription)
            }
        }
        
        state = .dataLoaded
        
        if showListener == nil {
            addShowListener()
        }
    }
    
    func addShowListener() {
        showListener = db.collection("shows").document(show.id).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let editedShow = try? snapshot!.data(as: Show.self) {
                    self.show = editedShow
                }
            }
        }
    }
    
    @MainActor
    func getShowLineup() async throws {
        showLineup = try await DatabaseService.shared.getShowLineup(forShow: show)
    }
    
    func showDirectionsInMaps() {
        let showPlacemark = MKPlacemark(coordinate: show.coordinates)
        let showMapItem = MKMapItem(placemark: showPlacemark)
        showMapItem.name = show.venue
        
        showMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
    
    func removeShowListener() {
        showListener?.remove()
    }
}
