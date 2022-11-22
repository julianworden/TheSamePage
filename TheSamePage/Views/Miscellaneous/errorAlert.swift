//
//  View+errorAlert.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/19/22.
//

import Foundation
import SwiftUI

extension View {
    func errorAlert(
        isPresented: Binding<Bool>,
        message: String,
        buttonText: String = "OK",
        tryAgainAction: (() async -> Void)? = nil,
        tryAgainButtonText: String = "Try Again"
    ) -> some View {
        return alert(
            "Error",
            isPresented: isPresented,
            actions: {
                if tryAgainAction == nil {
                    Button(buttonText) { }
                }
                
                if let tryAgainAction {
                    Button(tryAgainButtonText) {
                        Task {
                            await tryAgainAction()
                        }
                    }
                }
            }, message: {
                Text(message)
            }
        )
    }
}
