//
//  LoggedInUserProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct LoggedInUserProfileView: View {
    @StateObject var viewModel: UserProfileRootViewModel
    
    @Binding var userIsLoggedOut: Bool
    @Binding var selectedTab: Int
    
    let columns = [GridItem(.fixed(149), spacing: 15), GridItem(.fixed(149), spacing: 15)]
    
    init(userIsLoggedOut: Binding<Bool>, selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: UserProfileRootViewModel(user: nil, bandMember: nil))
        _userIsLoggedOut = Binding(projectedValue: userIsLoggedOut)
        _selectedTab = Binding(projectedValue: selectedTab)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
            
                ScrollView {
                    VStack {
                        if viewModel.profileImageUrl != nil  {
                            ProfileAsyncImage(url: URL(string: viewModel.profileImageUrl!))
                        } else {
                            NoImageView()
                                .padding(.horizontal)
                        }
                        
                        if let bands = viewModel.bands {
                            HStack {
                                SectionTitle(title: "Member of")
                                
                                NavigationLink {
                                    AddEditBandView(userIsOnboarding: .constant(false), bandToEdit: nil)
                                } label: {
                                    Image(systemName: "plus")
                                }
                                .padding(.trailing)
                            }
                            
                            UserBandList(bands: bands)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                do {
                    try await viewModel.initializeUser(user: nil)
                    try await viewModel.getBands(forUser: nil)
                } catch {
                    print(error)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out") {
                        do {
                            try viewModel.logOut()
                            userIsLoggedOut = true
                            selectedTab = 0
                        } catch {
                            print(error)
                        }
                    }
                }
            }
                
        }
    }
}

struct LoggedInUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserProfileView(userIsLoggedOut: .constant(false), selectedTab: .constant(4))
    }
}
