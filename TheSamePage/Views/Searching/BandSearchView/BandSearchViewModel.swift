//
//  BandSearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import Foundation
import Typesense

@MainActor
final class BandSearchViewModel: ObservableObject {
    @Published var fetchedBands = [SearchResultHit<Band>]()
    @Published var queryText = ""
    @Published var isSearching = false {
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
    
    func clearFetchedResultsArrays() {
        fetchedBands = [SearchResultHit<Band>]()
    }
}
