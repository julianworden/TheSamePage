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
        if count > 0 {
            ZStack(alignment: .topTrailing) {
                Color.clear
                Text(countText)
                    .font(.system(size: countFontSize))
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
                    // custom positioning in the top-right corner
                    .alignmentGuide(.top) { $0[.bottom] - ($0.height * 0.25) }
                    .alignmentGuide(.trailing) { getTrailingAlignmentPosition(viewDimensions: $0) }
            }
        }
    }

    var countFontSize: CGFloat {
        if count <= 9 {
            return 14
        } else if count >= 10 {
            return 10
        } else {
            return 0
        }
    }

    var countText: String {
        if count >= 1 && count <= 99 {
            return String(count)
        } else if count >= 100 {
            return "99+"
        } else {
            return ""
        }
    }

    func getTrailingAlignmentPosition(viewDimensions: ViewDimensions) -> CGFloat {
        if count >= 1 && count <= 99 {
            return viewDimensions[.trailing]
        } else {
            return viewDimensions[.trailing] - viewDimensions.width * 0.1
        }
    }
}
struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        Badge(count: 10)
    }
}
