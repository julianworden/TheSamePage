//
//  MemberSearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import Foundation
import Typesense

class MemberSearchViewModel: ObservableObject {
    @Published var fetchedResults = [SearchResultHit<User>]()
    @Published var queryText = ""
    
    var band: Band?
    
    
    init(band: Band?) {
        self.band = band
    }
    
    @MainActor
    func fetchUsers(searchQuery: String) async {
        guard !queryText.isEmpty else { return }
        
        let collectionParams = MultiSearchCollectionParameters(q: searchQuery, collection: "users")
        let searchParams = MultiSearchParameters(queryBy: "username")
        
        do {
            let (data, _) = try await TypesenseController.client.multiSearch().perform(searchRequests: [collectionParams], commonParameters: searchParams, for: User.self)
            fetchedResults = (data?.results[0].hits) ?? []
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
}
