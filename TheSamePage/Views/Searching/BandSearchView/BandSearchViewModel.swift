//
//  BandSearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import Foundation
import Typesense

@MainActor
class BandSearchViewModel: ObservableObject {
    enum BandSearchViewModelError: Error {
        case searchFailed(message: String)
    }
    
    @Published var fetchedBands = [SearchResultHit<Band>]()
    @Published var queryText = ""
    
    func fetchBands(searchQuery: String) async throws {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: "bands")
        let searchParams = MultiSearchParameters(queryBy: "name")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: Band.self)
            fetchedBands = (data?.results[0].hits) ?? []
        } catch {
            throw BandSearchViewModelError.searchFailed(message: "Band search failed")
        }
    }
}
