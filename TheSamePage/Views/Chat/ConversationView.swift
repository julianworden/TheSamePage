//
//  ConversationView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import SwiftUI

struct ConversationView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ConversationViewModel
    
    @State private var sendButtonIsDisabled = true
    
    init(show: Show? = nil, userId: String? = nil) {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(show: show, userId: userId))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                List(viewModel.messages) { message in
                    VStack {
                        Text(message.text)
                        Text(message.senderFullName)
                    }
                }
                .listStyle(.plain)
                
                Spacer()
                
                HStack {
                    TextField("Message", text: $viewModel.messageText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        Task {
                            await viewModel.sendChatMessage()
                            viewModel.messageText = ""
                        }
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .disabled(sendButtonIsDisabled)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.configureChat()
            viewModel.addChatListener()
        }
        .onChange(of: viewModel.messageText) { messageText in
            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sendButtonIsDisabled = false
            } else {
                sendButtonIsDisabled = true
            }
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView()
    }
}
