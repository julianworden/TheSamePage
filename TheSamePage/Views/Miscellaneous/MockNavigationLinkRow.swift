//
//  MockNavigationLinkRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/31/23.
//

import SwiftUI

/// To be used in form as a button label that pushes to a new view. Not to be used with buttons that navigate to a new view
/// after performing an asynchronous task successfully.
struct MockNavigationLinkRow: View {
    let text: String
    let chevronColor: Color

    init(text: String, chevronColor: Color = .secondary) {
        self.text = text
        self.chevronColor = chevronColor
    }

    var body: some View {
        HStack {
            Text(text)

            Spacer()

            Image(systemName: "chevron.right")
                .fontWeight(.semibold)
                .imageScale(.small)
                .foregroundColor(chevronColor)
                .opacity(0.6)
        }
    }
}

struct MockNavigationLinkRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Form {
                Button {

                } label: {
                    MockNavigationLinkRow(text: "Test")
                }
                .tint(.primary)

                NavigationLink {
                    EmptyView()
                } label: {
                    Text("Text")
                }
            }
        }
    }
}
