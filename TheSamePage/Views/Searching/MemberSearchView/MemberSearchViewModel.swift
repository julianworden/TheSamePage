//
//  MemberSearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import Foundation

class MemberSearchViewModel: ObservableObject {
    @Published var fetchedUsers = [User]()
    @Published var searchText = ""
    
    @MainActor
    func getUsers() async throws {
        fetchedUsers = try await DatabaseService.shared.searchForUsers(emailAddress: searchText)
    }
}
