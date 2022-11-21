//
//  AsyncButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

// https://www.swiftbysundell.com/articles/building-an-async-swiftui-button/
struct AsyncButton<Label: View>: View {
    /// True when the button that's using this label is disabled. When true,
    /// the ProgressView is shown next to the title.
    @State private var buttonIsDisabled = false
    @State private var progressViewIsShown = false
    
    var action: () async -> Void
    @ViewBuilder var label: () -> Label
    
    var body: some View {
        Button {
            Task {
                progressViewIsShown = true
                
                await action()
                
                buttonIsDisabled = false
                progressViewIsShown = false
            }
        } label: {
            HStack(spacing: 5) {
                label()
                
                if progressViewIsShown {
                    ProgressView()
                }
            }
        }
        .disabled(buttonIsDisabled)
    }
}

struct AsyncButton_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButton {
            
        } label: {
            Text("Hello")
        }
    }
}
