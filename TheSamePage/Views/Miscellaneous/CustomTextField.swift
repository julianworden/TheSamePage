//
//  UsernameTextField.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/5/23.
//

import SwiftUI

/// A convenience view for adding a TextField that does not allow spaces and does not auto capitalize or correct text input.
struct CustomTextField: View {
    @Binding var text: String

    let label: String
    let keyboardType: UIKeyboardType

    init(_ label: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) {
        _text = Binding(projectedValue: text)
        self.label = label
        self.keyboardType = keyboardType
    }

    var body: some View {
        TextField(label, text: $text)
            .keyboardType(keyboardType)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onChange(of: text) { newText in
                text = newText.replacing(" ", with: "")
            }
    }
}

//struct UsernameTextField_Previews: PreviewProvider {
//    static var previews: some View {
//        UsernameTextField("Hello World", label: "Stuff")
//    }
//}
