//
//  ProfileImageStyle.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/12/22.
//

import Foundation
import SwiftUI

struct ProfileImageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 135, height: 135)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(.white, lineWidth: 3)
            }
    }
}

extension View {
    func profileImageStyle() -> some View {
        modifier(ProfileImageStyle())
    }
}
