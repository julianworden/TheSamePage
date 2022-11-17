//
//  Task+sleepInSeconds.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/16/22.
//

import Foundation

// https://stackoverflow.com/questions/68715266/how-to-await-x-seconds-with-async-await-swift-5-5
extension Task where Success == Never, Failure == Never {
    /// A convenience method for using Task.sleep(nanoseconds:) with seconds instead of nanoseconds. Once
    /// the minimum target is iOS 16+, this method will no longer be necessary, as iOS 16 allows
    /// Task.sleep(until: .now + .seconds(5), clock: .continuous), for example.
    /// - Parameter seconds: The amount of seconds to wait before executing any code
    /// that comes after this method is called
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
