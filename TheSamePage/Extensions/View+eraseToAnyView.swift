//
//  View+eraseToAnyView.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/12/23.
//

import Foundation
import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
