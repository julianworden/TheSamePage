//
//  SmallIconStyle.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/12/22.
//

import Foundation
import SwiftUI

extension Image {
    func smallIconStyle() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
    }
}
