//
//  AsyncButtonLabel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

/// A convenience view for adding a ProgressView to a disabled button that's
/// performing asynchronous work.
struct AsyncButtonLabel: View {
    /// True when the button that's using this label is disabled. When true,
    /// the ProgressView is shown next to the title.
    @Binding var buttonIsDisabled: Bool
    
    /// The title of the button.
    let title: String
    
    var body: some View {
        HStack(spacing: 5) {
            Text(title)
            
            if buttonIsDisabled {
                ProgressView()
            }
        }
    }
}

struct AsyncButtonLabel_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButtonLabel(buttonIsDisabled: .constant(false), title: "Create Show")
    }
}
