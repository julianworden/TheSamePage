//
//  AddLinkView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import SwiftUI

struct AddEditLinkView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddEditLinkViewModel
    
    init(link: PlatformLink?, band: Band) {
        _viewModel = StateObject(wrappedValue: AddEditLinkViewModel(link: link, band: band))
    }
    
    var body: some View {
        Form {
            Picker("Choose Platform", selection: $viewModel.linkPlatform) {
                ForEach(LinkPlatform.allCases) { platform in
                    if platform != LinkPlatform.none {
                        Text(platform.rawValue)
                    }
                }
            }
            TextField("URL", text: $viewModel.enteredText)
        }
        .navigationTitle(viewModel.linkUrl == "" ? "Add Link" : "Edit Link")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    do {
                        viewModel.createLink()
                        try viewModel.uploadBandLink()
                        dismiss()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

struct AddLinkView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddEditLinkView(link: PlatformLink.example, band: Band.example)
        }
    }
}
