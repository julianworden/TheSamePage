//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

/// Displayed when a user is viewing somebody else's profile.
struct OtherUserProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: OtherUserProfileViewModel
    @StateObject var sheetNavigator = OtherUserProfileViewSheetNavigator()
    
    init(user: User?, uid: String? = nil, bandMember: BandMember? = nil, isPresentedModally: Bool = false) {
        _viewModel = StateObject(wrappedValue: OtherUserProfileViewModel(user: user, uid: uid, bandMember: bandMember, isPresentedModally: isPresentedModally))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()
                
            case .dataLoaded, .error:
                if let user = viewModel.user {
                    ScrollView {
                        OtherUserProfileHeader(viewModel: viewModel)
                        
                            HStack {
                                SectionTitle(title: "Member of")
                            }

                        if !viewModel.bands.isEmpty {
                            OtherUserBandList(viewModel: viewModel)
                        } else {
                            NoDataFoundMessage(message: "This user is not a member of any bands")
                                .padding(.top)
                        }
                    }
                    .navigationTitle(user.name)
                    .toolbar {
                        // TODO: Chat button here

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button {
                                    sheetNavigator.sheetDestination = .sendBandInvite(user: user)
                                } label: {
                                    Label("Send Band Invite", systemImage: "envelope")
                                }

                                if let shortenedDynamicLink = viewModel.shortenedDynamicLink {
                                    ShareLink(item: ".\(shortenedDynamicLink.absoluteString)") {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                            } label: {
                                EllipsesMenuIcon()
                            }
                            .fullScreenCover(isPresented: $sheetNavigator.presentSheet) {
                                sheetNavigator.sheetView()
                            }
                        }
                    }
                }
                
            default:
                ErrorMessage(message: "Invalid viewState: \(viewModel.viewState)")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isPresentedModally {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            okButtonAction: {
                dismiss()
            }
        )
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OtherUserProfileView(user: User.example)
        }
    }
}
