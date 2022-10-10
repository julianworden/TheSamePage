//
//  MyHostedShowsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/9/22.
//

import SwiftUI

struct MyHostedShowsView: View {
    @ObservedObject var viewModel: MyShowsViewModel
    
    @Binding var addEditShowViewIsShowing: Bool
    
    var body: some View {
        Group {
            if !viewModel.hostedShows.isEmpty {
                ScrollView {
                    ForEach(viewModel.hostedShows) { show in
                        NavigationLink {
                            ShowDetailsRootView(show: show)
                        } label: {
                            LargeListRow(show: show, joinedShow: nil)
                        }
                        .foregroundColor(.black)
                    }
                }
                .onDisappear {
                    viewModel.removeHostedShowsListener()
                }
            } else {
                VStack {
                    Text("You're not hosting any shows.")
                        .font(.body.italic())
                    
                    Button {
                        addEditShowViewIsShowing = true
                    } label: {
                        Text("Tap here to create a show.")
                    }
                }
                .padding(.top)
            }
        }
        .task {
            do {
                try await viewModel.getHostedShows()
            } catch {
                print(error)
            }
        }
        .onDisappear {
            viewModel.removeHostedShowsListener()
        }
    }
}

struct MyHostedShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyHostedShowsView(viewModel: MyShowsViewModel(), addEditShowViewIsShowing: .constant(false))
    }
}
