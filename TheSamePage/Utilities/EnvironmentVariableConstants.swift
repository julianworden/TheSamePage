//
//  EnvironmentVariableConstants.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/20/23.
//

import Foundation

struct EnvironmentVariableConstants {
    static var unitTestsAreRunning: Bool {
        return ProcessInfo.processInfo.environment["testing"] == "true"
    }
    static let testing = "testing"
}
