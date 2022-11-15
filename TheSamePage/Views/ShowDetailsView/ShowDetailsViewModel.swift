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
    
    var showHasTimes: Bool {
        show.doorsTime != nil ||
        show.musicStartTime != nil ||
        show.loadInTime != nil ||
        show.endTime != nil
    }
    
    var mapAnnotations: [CustomMapAnnotation] {
        let venue = CustomMapAnnotation(coordinates: show.coordinates)
        return [venue]
    }
    
    init(show: Show) {
        self.show = show
        
        Task { @MainActor in
            do {
                showParticipants = try await DatabaseService.shared.getShowLineup(forShow: show)
            } catch {
                state = .error(message: error.localizedDescription)
            }
        }
        
        state = .dataLoaded
    }
    
    func removeShowTimeFromShow(showTimeType: ShowTimeType) {
        Task { @MainActor in
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
            if let showLoadInTime = show.loadInTime {
                return "\(showTimeType.rowTitleText) \(Date(timeIntervalSince1970: showLoadInTime).timeShortened)"
            }
        case .musicStart:
            if let showMusicStartTime = show.musicStartTime {
                return "\(showTimeType.rowTitleText) \(Date(timeIntervalSince1970: showMusicStartTime).timeShortened)"
            }
        case .end:
            if let showEndTime = show.endTime {
                return "\(showTimeType.rowTitleText) \(Date(timeIntervalSince1970: showEndTime).timeShortened)"
            }
        case .doors:
            if let showDoorsTime = show.doorsTime {
                return "\(showTimeType.rowTitleText) \(Date(timeIntervalSince1970: showDoorsTime).timeShortened)"
            }
        }
        
        return ""
    }
    
    func addShowListener() {
        showListener = db.collection(FbConstants.shows).document(show.id).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let editedShow = try? snapshot!.data(as: Show.self) {
                    Task { @MainActor in
                        self.show = editedShow
                    }
                }
            }
            
            // TODO: Detect when the show is deleted and dismiss the view somehow
        }
    }
    
    func getBacklineItems(forShow show: Show) async {
        showBacklineListener = db.collection(FbConstants.shows).document(show.id).collection("backlineItems").addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                let documents = snapshot!.documents
                
                guard !documents.isEmpty else { return }
                
                let drumKitBacklineItems = documents.compactMap { try? $0.data(as: DrumKitBacklineItem.self) }
                
                if !drumKitBacklineItems.isEmpty {
                    Task { @MainActor in
                        self.drumKitBacklineItems = drumKitBacklineItems
                    }
                }
                
                let fetchedBacklineItems = documents.compactMap { try? $0.data(as: BacklineItem.self) }
                
                for backlineItem in fetchedBacklineItems {
                    switch backlineItem.type {
                    case BacklineItemType.percussion.rawValue:
                        if backlineItem.name != PercussionGearType.fullKit.rawValue &&
                           !self.percussionBacklineItems.contains(backlineItem) {
                            Task { @MainActor in
                                self.percussionBacklineItems.append(backlineItem)
                            }
                        }
                    case BacklineItemType.electricGuitar.rawValue:
                        if !self.electricGuitarBacklineItems.contains(backlineItem) {
                            Task { @MainActor in
                                self.electricGuitarBacklineItems.append(backlineItem)
                            }
                        }
                    case BacklineItemType.bassGuitar.rawValue:
                        if !self.bassGuitarBacklineItems.contains(backlineItem) {
                            Task { @MainActor in
                                self.bassGuitarBacklineItems.append(backlineItem)
                            }
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
