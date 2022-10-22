//
//  ShowBacklineTabViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import FirebaseFirestore
import Foundation

class ShowBacklineTabViewModel: ObservableObject {
    @Published var drumKitBacklineItems = [DrumKitBacklineItem]()
    @Published var percussionBacklineItems = [BacklineItem]()
    @Published var bassGuitarBacklineItems = [BacklineItem]()
    @Published var electricGuitarBacklineItems = [BacklineItem]()
    
    let show: Show
    let db = Firestore.firestore()
    var showBacklineListener: ListenerRegistration?
    
    init(show: Show) {
        self.show = show
    }
    
    @MainActor
    func getBacklineItems(forShow show: Show) async {
        showBacklineListener = db.collection("shows").document(show.id).collection("backlineItems").addSnapshotListener { snapshot, error in
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
                        if backlineItem.name != PercussionGearType.fullKit.rawValue {
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
    
    func removeShowBacklineListener() {
        showBacklineListener?.remove()
    }
}
