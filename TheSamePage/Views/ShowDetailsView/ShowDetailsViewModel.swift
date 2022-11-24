//
//  ShowDetailsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import FirebaseFirestore
import Foundation
import MapKit

@MainActor
final class ShowDetailsViewModel: ObservableObject {
    @Published var show: Show
    @Published var showParticipants = [ShowParticipant]()
    @Published var selectedTab = SelectedShowDetailsTab.details
    @Published var state = ViewState.dataLoading
    
    @Published var drumKitBacklineItems = [DrumKitBacklineItem]()
    @Published var percussionBacklineItems = [BacklineItem]()
    @Published var bassGuitarBacklineItems = [BacklineItem]()
    @Published var electricGuitarBacklineItems = [BacklineItem]()
    
    let db = Firestore.firestore()
    var showListener: ListenerRegistration?
    var showBacklineListener: ListenerRegistration?
    
    var showSlotsRemainingMessage: String {
        let slotsRemainingCount = show.maxNumberOfBands - showParticipants.count
        
        if slotsRemainingCount == 1 {
            return "\(slotsRemainingCount) slot remaining"
        } else {
            return "\(slotsRemainingCount) slots remaining"
        }
    }
    
    var noShowTimesMessage: String {
        if show.loggedInUserIsShowHost {
            return "No times have been added to this show. Choose from the buttons above to add show times."
        } else {
            return "No times have been added to this show. Only the show's host can add times."
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
                showParticipants = try await DatabaseService.shared.getShowLineup(forShow: show)
            } catch {
                state = .error(message: error.localizedDescription)
            }
        }
        
        state = .dataLoaded
    }
    
    func removeShowTimeFromShow(showTimeType: ShowTimeType) {
        Task {
            do {
                try await DatabaseService.shared.deleteTimeFromShow(delete: showTimeType, fromShow: show)
                
                switch showTimeType {
                case .loadIn:
                    show.loadInTime = nil
                case .musicStart:
                    show.musicStartTime = nil
                case .end:
                    show.endTime = nil
                case .doors:
                    show.doorsTime = nil
                }
            } catch {
                print(error)
            }
        }
    }
    
    func getShowTimeRowText(forShowTimeType showTimeType: ShowTimeType) -> String {
        switch showTimeType {
        case .loadIn:
            if let showLoadInTime = show.unixLoadInTimeAsDate {
                return "\(showTimeType.rowTitleText) \(showLoadInTime.timeShortened)"
            }
        case .musicStart:
            if let showMusicStartTime = show.unixMusicStartTimeAsDate {
                return "\(showTimeType.rowTitleText) \(showMusicStartTime.timeShortened)"
            }
        case .end:
            if let showEndTime = show.unixEndTimeAsDate {
                return "\(showTimeType.rowTitleText) \(showEndTime.timeShortened)"
            }
        case .doors:
            if let showDoorsTime = show.unixDoorsTimeAsDate {
                return "\(showTimeType.rowTitleText) \(showDoorsTime.timeShortened)"
            }
        }
        
        return ""
    }
    
    func addShowListener() {
        showListener = db.collection(FbConstants.shows).document(show.id).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let editedShow = try? snapshot!.data(as: Show.self) {
                    self.show = editedShow
                } else {
                    print("edited show not found")
                }
            } else if error != nil {
                print(error)
            }
        }
    }
    
    func getBacklineItems(forShow show: Show) async {
        showBacklineListener = db.collection(FbConstants.shows).document(show.id).collection("backlineItems").addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                let documents = snapshot!.documents
                
                guard !documents.isEmpty else { return }
                
                let drumKitBacklineItems = documents.compactMap { try? $0.data(as: DrumKitBacklineItem.self) }
                
                if !drumKitBacklineItems.isEmpty {
                    self.drumKitBacklineItems = drumKitBacklineItems
                }
                
                let fetchedBacklineItems = documents.compactMap { try? $0.data(as: BacklineItem.self) }
                
                for backlineItem in fetchedBacklineItems {
                    switch backlineItem.type {
                    case BacklineItemType.percussion.rawValue:
                        if backlineItem.name != PercussionGearType.fullKit.rawValue &&
                           !self.percussionBacklineItems.contains(backlineItem) {
                            self.percussionBacklineItems.append(backlineItem)
                        }
                    case BacklineItemType.electricGuitar.rawValue:
                        if !self.electricGuitarBacklineItems.contains(backlineItem) {
                            self.electricGuitarBacklineItems.append(backlineItem)
                        }
                    case BacklineItemType.bassGuitar.rawValue:
                        if !self.bassGuitarBacklineItems.contains(backlineItem) {
                            self.bassGuitarBacklineItems.append(backlineItem)
                        }
                    default:
                        // TODO: Change and add error state
                        break
                    }
                }
            }
        }
    }
    
    func removeShowListener() {
        showListener?.remove()
    }
    
    func removeShowBacklineListener() {
        showBacklineListener?.remove()
    }
    
    func showDirectionsInMaps() {
        let showPlacemark = MKPlacemark(coordinate: show.coordinates)
        let showMapItem = MKMapItem(placemark: showPlacemark)
        showMapItem.name = show.venue
        
        showMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
}
