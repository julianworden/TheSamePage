//
//  ConversationViewMessagesList.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/14/23.
//

import SwiftUI

struct ConversationViewMessagesList: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @ObservedObject var viewModel: ConversationViewModel

    @FocusState var keyboardIsFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if viewModel.messages.count % 20 == 0 && !viewModel.messages.isEmpty {
                    AsyncButton {
                        await viewModel.getMoreMessages(before: viewModel.messages.first!.sentTimestamp)
                    } label: {
                        Text("Load More")
                    }
                }

                ForEach(Array(viewModel.messages.enumerated()), id: \.offset) { index, message in
                    ChatBubble(chatMessage: message)
                        .id(index)
                }
                .padding(.horizontal)
                .onAppear {
                    proxy.scrollTo(viewModel.messages.count - 1)
                }
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

                Button {
                    Task {
                        await viewModel.sendMessageButtonTapped(by: loggedInUserController.loggedInUser)
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.count - 1, anchor: .bottom)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up")
                }
                .disabled(viewModel.sendButtonIsDisabled)
            }
            .padding([.bottom, .horizontal])
            .onChange(of: viewModel.messages) { [oldMessagesArray = viewModel.messages] newMessagesArray in
                // Keeps this from being called when the user loads older messages or opens ConversationView.
                if newMessagesArray.count == 20 && !oldMessagesArray.isEmpty {
                    // User sent or received new message
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.count - 1)
                    }
                }
            }
            .onChange(of: viewModel.messages.count) { [oldCount = viewModel.messages.count] newCount in
                // Keeps this from being called when view appears.
                if newCount > 20 {
                    // User tapped load more button
                    let differenceBetweenMessageCounts = newCount - oldCount
                    proxy.scrollTo(differenceBetweenMessageCounts - 1, anchor: .top)
                } else if newCount == 20 && oldCount != 0 {
                    // User received a new message after tapping the load more button.
                    withAnimation {
                        proxy.scrollTo(newCount - 1)
                    }
                } else if newCount == 20 && oldCount == 0 {
                    proxy.scrollTo(newCount - 1)
                } else if newCount < 21 {
                    withAnimation {
                        proxy.scrollTo(newCount - 1)
                    }
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
}

struct ConversationViewMessagesList_Previews: PreviewProvider {
    static var previews: some View {
        ConversationViewMessagesList(viewModel: ConversationViewModel())
    }
}
