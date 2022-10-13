//
//  ShowTimeTabViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import Foundation

class ShowTimeTabViewModel: ObservableObject {
    let show: Show
    var showDoorsTime: Date?
    var showMusicStartTime: Date?
    var showLoadInTime: Date?
    var showEndTime: Date?
       
    init(show: Show) {
        self.show = show
        
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
}
