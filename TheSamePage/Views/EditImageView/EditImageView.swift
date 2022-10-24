//
//  EditImageView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/23/22.
//

import SwiftUI

struct EditImageView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: EditImageViewModel
    
    /// The image that is selected within the ImagePicker
    @Binding var updatedImage: UIImage?
    
    @State private var imagePickerIsShowing = false
    
    let image: Image?
    
    init(show: Show, image: Image?, updatedImage: Binding<UIImage?>) {
        _viewModel = StateObject(wrappedValue: EditImageViewModel(show: show))
        self.image = image
        _updatedImage = Binding(projectedValue: updatedImage)
    }
    
    var body: some View {
        VStack {
            if let updatedImage {
                Image(uiImage: updatedImage)
                    .resizable()
                    .scaledToFit()
            } else if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                NoImageView()
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    imagePickerIsShowing = true
                }
            }
        }
        .sheet(
            // TODO: Call viewModel.updateShowImage here instead and lock up UI while function is running with .navigationBackBarDisabled?
            isPresented: $imagePickerIsShowing,
            content: {
                ImagePicker(image: $updatedImage, pickerIsShowing: $imagePickerIsShowing)
            }
        )
        .onChange(of: updatedImage) { updatedImage in
            Task {
                do {
                    try await viewModel.updateShowImage(show: viewModel.show, withImage: updatedImage!)
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct EditImageView_Previews: PreviewProvider {
    static var previews: some View {
        EditImageView(show: Show.example, image: Image("photo"), updatedImage: .constant(nil))
    }
}
