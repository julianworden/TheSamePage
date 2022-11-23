//
//  NetworkController.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/22/22.
//

// TODO: Implement this in various spots in the app

import Foundation
import Network

@MainActor
class NetworkController: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkManager")
    var deviceIsOffline = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            print(path.status)
            if path.status == .unsatisfied {
                self.deviceIsOffline = true
                NotificationCenter.default.post(name: .deviceIsOffline, object: nil, userInfo: ["connectionStatus": "unsatisfied"])
            } else if path.status == .satisfied {
                if self.deviceIsOffline == true {
                    self.deviceIsOffline = false
                    NotificationCenter.default.post(name: .deviceIsOnline, object: nil, userInfo: ["connectionStatus": "satisfied"])
                }
            }
        }
        
        monitor.start(queue: queue)
    }
}
