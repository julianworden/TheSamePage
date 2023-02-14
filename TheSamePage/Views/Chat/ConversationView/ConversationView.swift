//
//  ConversationView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import SwiftUI

struct ConversationView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    @StateObject var viewModel: ConversationViewModel

    @FocusState var keyboardIsFocused: Bool
    
    init(chatId: String? = nil, show: Show? = nil, userId: String? = nil, chatParticipantUids: [String] = []) {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(chatId: chatId, show: show, userId: userId, chatParticipantUids: chatParticipantUids))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()

            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(Array(viewModel.messages.enumerated()), id: \.offset) { index, message in
                        ChatBubble(chatMessage: message)
                            .id(index)
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.count - 1)
                        }
                    }
                    .padding(.horizontal)
                }
                // Needed to prevent ScrollView from going behind the navigation bar. I don't know why
                .padding(.top, 0.5)
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)

                Spacer()

                HStack {
                    TextField("Message", text: $viewModel.messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .focused($keyboardIsFocused)

                    AsyncButton {
                        await viewModel.sendMessageButtonTapped(by: loggedInUserController.loggedInUser)
                        proxy.scrollTo(viewModel.messages.count - 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .disabled(viewModel.sendButtonIsDisabled)
                }
                .padding([.bottom, .horizontal])
                .onChange(of: viewModel.messages.count) { count in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.count - 1)
                    }
                }
                .onChange(of: keyboardIsFocused) { keyboardIsFocused in
                    if keyboardIsFocused {
                        Task { @MainActor in
                            try await Task.sleep(seconds: 0.5)
                            
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.count - 1)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ChatInfoView(show: viewModel.show, chatParticipantUids: viewModel.chatParticipantUids)
                } label: {
                    Image(systemName: "info.circle")
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            tryAgainAction: viewModel.callOnAppearMethods
        )
        .onChange(of: viewModel.messageText) { messageText in
            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.sendButtonIsDisabled = false
            } else {
                viewModel.sendButtonIsDisabled = true
            }
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(show: Show.example, chatParticipantUids: [])
    }
}
