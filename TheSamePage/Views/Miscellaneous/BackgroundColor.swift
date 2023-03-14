//
//  BackgroundColor.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/24/22.
//

import SwiftUI

struct BackgroundColor: View {
    var body: some View {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
    }
}

struct BackgroundColor_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundColor()
    }
}
