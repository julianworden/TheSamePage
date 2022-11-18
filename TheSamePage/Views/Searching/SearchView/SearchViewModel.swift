//
//  SearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/26/22.
//

import Foundation
import Typesense

@MainActor
final class SearchViewModel: ObservableObject {
    enum SearchViewModelError: Error {
        case searchFailed(message: String)
    }

    @Published var fetchedUsers = [SearchResultHit<User>]()
    @Published var fetchedBands = [SearchResultHit<Band>]()
    @Published var fetchedShows = [SearchResultHit<Show>]()
    @Published var queryText = ""
    @Published var searchType = SearchType.user {
        didSet {
            fetchedUsers = [SearchResultHit<User>]()
            fetchedBands = [SearchResultHit<Band>]()
            fetchedShows = [SearchResultHit<Show>]()
        }
    }

    var searchBarPrompt: String {
        switch searchType {
        case .user:
            return "Search by username"
        case .band:
            return "Search by band name"
        case .show:
            return "Search by show name"
        }
    }

    func fetchUsers(searchQuery: String) async throws {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: FbConstants.users)
        let searchParams = MultiSearchParameters(queryBy: "username")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: User.self)
            fetchedUsers = (data?.results[0].hits) ?? []
        } catch {
            throw SearchViewModelError.searchFailed(message: "User search failed")
        }
    }
    
    func fetchBands(searchQuery: String) async throws {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: FbConstants.bands)
        let searchParams = MultiSearchParameters(queryBy: "name")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: Band.self)
            fetchedBands = (data?.results[0].hits) ?? []
        } catch {
            throw SearchViewModelError.searchFailed(message: "Band search failed")
        }
    }
    
    func fetchShows(searchQuery: String) async throws {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: FbConstants.shows)
        let searchParams = MultiSearchParameters(queryBy: "name")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: Show.self)
            fetchedShows = (data?.results[0].hits) ?? []
        } catch {
            throw SearchViewModelError.searchFailed(message: "Show search failed \(error)")
        }
    }
}
