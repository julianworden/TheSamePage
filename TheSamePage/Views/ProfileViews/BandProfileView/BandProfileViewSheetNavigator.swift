//
//  BandProfileViewSheetNavigator.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/19/23.
//

import Foundation
import SwiftUI

@MainActor
final class BandProfileViewSheetNavigator: ObservableObject {
    @Published var presentSheet = false
    @Published var sheetDestination = BandProfileViewSheetNavigatorDestination.none {
        didSet {
            presentSheet = true
        }
    }

    func sheetView() -> AnyView {
        switch sheetDestination {
        case .bandSettingsView(let band):
            return BandSettingsView(band: band).eraseToAnyView()
            
        case .sendShowInviteView(let band):
            return SendShowInviteView(band: band).eraseToAnyView()
            
        default:
            return Text("Invalid sheetDestination: \(String(describing: sheetDestination))").eraseToAnyView()
        }
    }
}
