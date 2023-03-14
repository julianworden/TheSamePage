//
//  BandProfileViewSheetNavigator.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/19/23.
//

import Foundation
import SwiftUI

@MainActor
final class LoggedInUserProfileViewSheetNavigator: ObservableObject {
    @Published var presentSheet = false
    @Published var sheetDestination = LoggedInUserProfileViewSheetNavigatorDestination.none {
        didSet {
            presentSheet = true
        }
    }

    func sheetView() -> AnyView {
        switch sheetDestination {
        case .userSettingsView:
            return UserSettingsView().eraseToAnyView()
            
        default:
            return Text("Invalid sheetDestination: \(String(describing: sheetDestination))").eraseToAnyView()
        }
    }
}
