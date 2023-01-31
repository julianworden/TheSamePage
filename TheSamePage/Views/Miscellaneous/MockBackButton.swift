//
//  MockBackButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/31/23.
//

import SwiftUI

/// A view that allows for custom back button behavior without altering the style of the default back button.
struct MockBackButton: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "chevron.left")
            Text("Back")
        }
    }
}

struct MockBackButton_Previews: PreviewProvider {
    static var previews: some View {
        MockBackButton()
    }
}
