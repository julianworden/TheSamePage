//
//  ShowDetailsViewSheetNavigator.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/19/23.
//

import Foundation
import SwiftUI

@MainActor
final class ShowDetailsViewSheetNavigator: ObservableObject {
    @Published var presentSheet = false
    @Published var sheetDestination = ShowDetailsViewSheetNavigatorDestination.none {
        didSet {
            presentSheet = true
        }
    }

    func sheetView() -> AnyView {
        switch sheetDestination {
        case .showApplicationView(let show):
            return SendShowApplicationView(show: show).eraseToAnyView()

        case .showSettingsView(let show):
            return ShowSettingsView(show: show).eraseToAnyView()

        default:
            return Text("Invalid sheetDestination: \(String(describing: sheetDestination))").eraseToAnyView()
        }
    }
}
