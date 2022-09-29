//
//  MemberSearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import Foundation

class MemberSearchViewModel: ObservableObject {
    @Published var fetchedResults = [AnySearchable]()
    @Published var searchText = ""
    
    var band: Band?
    
    init(band: Band?) {
        self.band = band
    }
    
    @MainActor
    func getUsers() async throws {
        fetchedResults = try await DatabaseService.shared.performSearch(for: .user, withName: searchText)
    }
}
