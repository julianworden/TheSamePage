//
//  SearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/26/22.
//

import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    enum SearchViewModelError: Error {
        case invalidSearch(message: String)
    }
    
    @Published var fetchedResults = [AnySearchable]()
    @Published var searchText = ""
    @Published var searchType = SearchType.user {
        didSet {
            fetchedResults = [AnySearchable]()
        }
    }
    
    var searchBarPrompt: String {
        switch searchType {
        case .user:
            return "Search for a user by name"
        case .band:
            return "Search for a band by name"
        case .show:
            return "Search for a show by name"
        }
    }
    
    func performSearch() async throws {
        fetchedResults = try await DatabaseService.shared.performSearch(for: searchType, withName: searchText)
    }
}
