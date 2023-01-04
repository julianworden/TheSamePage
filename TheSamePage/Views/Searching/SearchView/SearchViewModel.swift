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
    @Published var fetchedUsers = [SearchResultHit<User>]()
    @Published var fetchedBands = [SearchResultHit<Band>]()
    @Published var fetchedShows = [SearchResultHit<Show>]()
    @Published var isSearching = false {
        didSet {
            clearFetchedResultsArrays()
        }
    }
    @Published var queryText = ""
    @Published var searchType = SearchType.user {
        didSet {
            clearFetchedResultsArrays()
        }
    }
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                if viewState != .dataNotFound && viewState != .dataLoaded {
                    print("Unknown viewState in SearchViewModel: \(viewState)")
                }
            }
        }
    }
    
    func clearFetchedResultsArrays() {
        fetchedUsers = [SearchResultHit<User>]()
        fetchedBands = [SearchResultHit<Band>]()
        fetchedShows = [SearchResultHit<Show>]()
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

    func fetchUsers(searchQuery: String) async {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: FbConstants.users)
        let searchParams = MultiSearchParameters(queryBy: "username")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: User.self)
            if let fetchedUsers = data?.results[0].hits {
                if fetchedUsers.isEmpty {
                    viewState = .dataNotFound
                } else {
                    self.fetchedUsers = fetchedUsers
                    viewState = .dataLoaded
                }
            } else {
                viewState = .error(message: "Failed to perform search, please try again.")
            }
        } catch {
            viewState = .error(message: "Failed to perform search, please try again. System error: \(error.localizedDescription)")
        }
    }
    
    func fetchBands(searchQuery: String) async {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: FbConstants.bands)
        let searchParams = MultiSearchParameters(queryBy: "name")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: Band.self)
            if let fetchedBands = data?.results[0].hits {
                if fetchedBands.isEmpty {
                    viewState = .dataNotFound
                } else {
                    self.fetchedBands = fetchedBands
                    viewState = .dataLoaded
                }
            } else {
                viewState = .error(message: "Failed to perform search, please try again.")
            }
        } catch {
            viewState = .error(message: "Failed to perform search, please try again. System error: \(error.localizedDescription)")
        }
    }
    
    func fetchShows(searchQuery: String) async {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: FbConstants.shows)
        let searchParams = MultiSearchParameters(queryBy: "name")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: Show.self)
            if let fetchedShows = data?.results[0].hits {
                if fetchedShows.isEmpty {
                    viewState = .dataNotFound
                } else {
                    self.fetchedShows = fetchedShows
                    viewState = .dataLoaded
                }
            } else {
                viewState = .error(message: "Failed to perform search, please try again.")
            }
        } catch {
            viewState = .error(message: "Failed to perform search, please try again. System error: \(error.localizedDescription)")
        }
    }
}
