//
//  NoDataFoundMessageWithButtonView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/18/23.
//

import SwiftUI

struct NoDataFoundMessageWithButtonView: View {
    @Binding var isPresentingSheet: Bool
    let shouldDisplayButton: Bool
    let buttonText: String
    let buttonImageName: String
    let message: String

    var body: some View {
        VStack(spacing: 7) {
            Text(message)
                .multilineTextAlignment(.center)

            if shouldDisplayButton {
                Button {
                    isPresentingSheet.toggle()
                } label: {
                    Label(buttonText, systemImage: buttonImageName)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

struct NoDataFoundMessageWithButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataFoundMessageWithButtonView(isPresentingSheet: .constant(false), shouldDisplayButton: true, buttonText: "Invite Band", buttonImageName: "plus", message: "No bands are playing this show.")
    }
}
