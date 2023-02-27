//
//  AddLinkView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import SwiftUI

// TODO: Refactor this whole view to be more consistent with the rest of the app

struct AddEditLinkView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddEditLinkViewModel
    
    init(link: PlatformLink?, band: Band) {
        _viewModel = StateObject(wrappedValue: AddEditLinkViewModel(link: link, band: band))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Choose Platform", selection: $viewModel.linkPlatform) {
                        ForEach(LinkPlatform.allCases) { platform in
                            if platform != LinkPlatform.none {
                                Text(platform.rawValue)
                            }
                        }
                    }
                    TextField("URL", text: $viewModel.enteredText)
                }

                Section {
                    Button("Save Link") {
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
            .navigationTitle(viewModel.linkUrl == "" ? "Add Link" : "Edit Link")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddLinkView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddEditLinkView(link: PlatformLink.example, band: Band.example)
        }
    }
}
