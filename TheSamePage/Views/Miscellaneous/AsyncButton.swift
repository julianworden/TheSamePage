//
//  AsyncButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

// https://www.swiftbysundell.com/articles/building-an-async-swiftui-button/
struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    @ViewBuilder var label: () -> Label
    
    @State private var progressViewIsShown = false
    
    var body: some View {
        Button {
            Task {
                progressViewIsShown = true
                
                await action()
                
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
