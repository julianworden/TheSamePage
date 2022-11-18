//
//  MemberSearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import Foundation
import Typesense

@MainActor
final class MemberSearchViewModel: ObservableObject {
    enum MemberSearchViewModelError: Error {
        case searchFailed(message: String)
    }
    
    @Published var fetchedResults = [SearchResultHit<User>]()
    @Published var queryText = ""
    
    var band: Band?
    
    
    init(band: Band?) {
        self.band = band
    }
    
    func fetchUsers(searchQuery: String) async throws {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: FbConstants.users)
        let searchParams = MultiSearchParameters(queryBy: "username")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: User.self)
            fetchedResults = (data?.results[0].hits) ?? []
        } catch {
            throw MemberSearchViewModelError.searchFailed(message: "User search failed")
        }
    }
}
