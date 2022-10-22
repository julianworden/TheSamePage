//
//  ShowTimeTabViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import FirebaseFirestore
import Foundation

@MainActor
class ShowTimeTabViewModel: ObservableObject {
    enum ShowTimeTabViewModelError: Error {
        case unexpectedNilValue(value: String)
    }
    
    let show: Show
    @Published var showDoorsTime: Date?
    @Published var showMusicStartTime: Date?
    @Published var showLoadInTime: Date?
    @Published var showEndTime: Date?
    
    var showTimeListener: ListenerRegistration?
    
    var formattedLoadInTime: String {
        showLoadInTime!.formatted(date: .omitted, time: .shortened)
    }
    
    var noShowTimesMessage: String {
        if show.loggedInUserIsShowHost {
            return "No times have been added to this show. Choose from the buttons above to add show times."
        } else {
            return "No times have been added to this show. Only the show's host can add times."
        }
    }
    
    var showHasTimes: Bool {
        showDoorsTime != nil ||
        showMusicStartTime != nil ||
        showLoadInTime != nil ||
        showEndTime != nil
    }
       
    init(show: Show) {
        self.show = show
    }
    
    func addShowTimesListener() throws {
        showTimeListener = DatabaseService.shared.db.collection("shows").document(show.id).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let updatedShow = try? snapshot?.data(as: Show.self) {
                    self.initializeShowTimes(forShow: updatedShow)
                } else {
                    print("Error in ShowTimeTabViewModel.addShowTimesListener()")
                }
            }
        }
    }
    
    func initializeShowTimes(forShow show: Show) {
        if let showDoorsTime = show.doorsTime {
            self.showDoorsTime = Date(timeIntervalSince1970: showDoorsTime)
        }
        
        if let showMusicStartTime = show.musicStartTime {
            self.showMusicStartTime = Date(timeIntervalSince1970: showMusicStartTime)
        }
        
        if let showLoadInTime = show.loadInTime {
            self.showLoadInTime = Date(timeIntervalSince1970: showLoadInTime)
        }
        
        if let showEndTime = show.endTime {
            self.showEndTime = Date(timeIntervalSince1970: showEndTime)
        }
    }
    
    func removeShowTimeFromShow(showTimeType: ShowTimeType) {
        Task {
            do {
                try await DatabaseService.shared.deleteTimeFromShow(delete: showTimeType, fromShow: show)
                
                switch showTimeType {
                case .loadIn:
                    showLoadInTime = nil
                case .musicStart:
                    showMusicStartTime = nil
                case .end:
                    showEndTime = nil
                case .doors:
                    showDoorsTime = nil
                }
            } catch {
                print(error)
            }
        }
    }
    
    func getRowText(forShowTimeType showTimeType: ShowTimeType) -> String? {
        switch showTimeType {
        case .loadIn:
            if showLoadInTime != nil {
                return "\(showTimeType.rowTitleText) \(showLoadInTime!.timeShortened)"
            }
        case .musicStart:
            if showMusicStartTime != nil {
                return "\(showTimeType.rowTitleText) \(showMusicStartTime!.timeShortened)"
            }
        case .end:
            if showEndTime != nil {
                return "\(showTimeType.rowTitleText) \(showEndTime!.timeShortened)"
            }
        case .doors:
            if showDoorsTime != nil {
                return "\(showTimeType.rowTitleText) \(showDoorsTime!.timeShortened)"
            }
        }
        
        return nil
    }
    
    func removeShowTimesListener() {
        showTimeListener?.remove()
    }
}
