//
//  ListIconStyle.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/12/22.
//

import Foundation
import SwiftUI

extension Image {
    func listIconStyle() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
    }
}
