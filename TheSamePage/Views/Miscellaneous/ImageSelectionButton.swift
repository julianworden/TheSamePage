//
//  ImageSelectionButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import SwiftUI

/// Presented when the user is expected to select an image for something (i.e. setting a profile picture).
///
/// This view does not contain an ImagePicker. Instead, it contains bindings that will communicate the state
/// of the picker and the selected image back to the parent, which should then handle presenting the ImagePicker.
struct ImageSelectionButton: View {
    @Binding var imagePickerIsShowing: Bool
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        Button {
            imagePickerIsShowing = true
        } label: {
            if let selectedImage {
                HStack {
                    Spacer()
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                    Spacer()
                }
            } else {
                NoImageView()
            }
        }
    }
}

struct ImageSelectionButton_Previews: PreviewProvider {
    static var previews: some View {
        ImageSelectionButton(imagePickerIsShowing: .constant(false), selectedImage: .constant(nil))
    }
}
