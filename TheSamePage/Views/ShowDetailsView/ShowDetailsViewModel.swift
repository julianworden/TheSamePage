//
//  ShowDetailsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import FirebaseFirestore
import Foundation
import MapKit
import SwiftUI
import UIKit.UIImage

@MainActor
final class ShowDetailsViewModel: ObservableObject {
    @Published var show: Show
    @Published var showParticipants = [ShowParticipant]()
    @Published var selectedTab = SelectedShowDetailsTab.details
    
    @Published var drumKitBacklineItems = [DrumKitBacklineItem]()
    @Published var percussionBacklineItems = [BacklineItem]()
    @Published var bassGuitarBacklineItems = [BacklineItem]()
    @Published var electricGuitarBacklineItems = [BacklineItem]()

    @Published var addBacklineSheetIsShowing = false
    @Published var bandSearchViewIsShowing = false
    @Published var editImageViewIsShowing = false
    @Published var showSettingsSheetIsShowing = false

    /// The image loaded from the ProfileAsyncImage
    @Published var showImage: Image?
    /// A new image set within EditImageView
    @Published var updatedImage: UIImage?
    
    let db = Firestore.firestore()

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                if viewState != .dataNotFound && viewState != .dataLoaded {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }
    
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
            return "No times have been added to this show. Use the buttons above to add show times."
        } else {
            return "No times have been added to this show. Only the show's host can add times."
        }
    }
    
    var mapAnnotations: [CustomMapAnnotation] {
        let venue = CustomMapAnnotation(coordinates: show.coordinates)
        return [venue]
    }

    var showHasBackline: Bool {
        return !percussionBacklineItems.isEmpty ||
        !drumKitBacklineItems.isEmpty ||
        !bassGuitarBacklineItems.isEmpty ||
        !electricGuitarBacklineItems.isEmpty
    }

    var noBacklineMessageText: String {
        if !show.loggedInUserIsInvolvedInShow {
            return "This show has no backline. You must be participating in this show to add backline to it."
        } else {
            return "This show has no backline."
        }
    }
    
    init(show: Show) {
        self.show = show
    }

    func callOnAppearMethods() async {
        await getLatestShowData()
        await getShowParticipants()
        await getBacklineItems()
        viewState = .dataLoaded
    }

    func timeForShowExists(showTimeType: ShowTimeType) -> Bool {
        switch showTimeType {
        case .loadIn:
            guard show.loadInTime != nil else {
                return false
            }
            return true

        case .musicStart:
            guard show.musicStartTime != nil else {
                return false
            }
            return true

        case .end:
            guard show.endTime != nil else {
                return false
            }
            return true

        case .doors:
            guard show.doorsTime != nil else {
                return false
            }
            return true
        }
    }
    
    func getLatestShowData() async {
        do {
            show = try await DatabaseService.shared.getLatestShowData(showId: show.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getShowParticipants() async {
        do {
            showParticipants = try await DatabaseService.shared.getShowLineup(forShow: show)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getBacklineItems() async {
        do {
            let backlineItemDocuments = try await DatabaseService.shared.getBacklineItems(forShow: show).documents

            guard !backlineItemDocuments.isEmpty else {
                clearAllBacklineItems()
                return
            }

            let drumKitBacklineItems = backlineItemDocuments.compactMap { try? $0.data(as: DrumKitBacklineItem.self) }

            if !drumKitBacklineItems.isEmpty {
                self.drumKitBacklineItems = drumKitBacklineItems
            }

            let fetchedBacklineItems = backlineItemDocuments.compactMap { try? $0.data(as: BacklineItem.self) }

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
                    viewState = .error(message: "Attempted to fetch invalid BacklineItemType. Please try again")
                }
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func removeShowTimeFromShow(showTimeType: ShowTimeType) async {
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
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getShowTimeRowText(forShowTimeType showTimeType: ShowTimeType) -> String {
        switch showTimeType {
        case .loadIn:
            if let showLoadInTime = show.loadInTime?.unixDateAsDate {
                return "\(showTimeType.rowTitleText) \(showLoadInTime.timeShortened)"
            } else {
                return "Not Set"
            }
        case .musicStart:
            if let showMusicStartTime = show.musicStartTime?.unixDateAsDate {
                return "\(showTimeType.rowTitleText) \(showMusicStartTime.timeShortened)"
            } else {
                return "Not Set"
            }
        case .end:
            if let showEndTime = show.endTime?.unixDateAsDate {
                return "\(showTimeType.rowTitleText) \(showEndTime.timeShortened)"
            } else {
                return "Not Set"
            }
        case .doors:
            if let showDoorsTime = show.doorsTime?.unixDateAsDate {
                return "\(showTimeType.rowTitleText) \(showDoorsTime.timeShortened)"
            } else {
                return "Not Set"
            }
        }
    }

    func clearAllBacklineItems() {
        drumKitBacklineItems = []
        percussionBacklineItems = []
        bassGuitarBacklineItems = []
        electricGuitarBacklineItems = []
    }
    
    func showDirectionsInMaps() {
        let showPlacemark = MKPlacemark(coordinate: show.coordinates)
        let showMapItem = MKMapItem(placemark: showPlacemark)
        showMapItem.name = show.venue
        
        showMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
}
