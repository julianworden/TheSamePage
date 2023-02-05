//
//  UsernameTextField.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/5/23.
//

import SwiftUI

struct UsernameTextField: View {
    @Binding var text: String

    let label: String

    init(_ label: String, text: Binding<String>) {
        _text = Binding(projectedValue: text)
        self.label = label
    }

    var body: some View {
        TextField(label, text: $text)
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
