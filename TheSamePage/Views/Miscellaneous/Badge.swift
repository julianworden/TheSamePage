//
//  Badge.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/23/23.
//

import SwiftUI

// https://stackoverflow.com/questions/65792449/how-can-i-add-a-badge-to-a-leading-navigationbaritems-in-swiftui-and-ios-14
struct Badge: View {
    let count: Int

    var body: some View {
        if count != 0 {
            ZStack(alignment: .topTrailing) {
                Color.clear
                Text(String(count))
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
                    // custom positioning in the top-right corner
                    .alignmentGuide(.top) { $0[.bottom] }
                    .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.10 }
            }
        }
    }
}
struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        Badge(count: 2)
    }
}
