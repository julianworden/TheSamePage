//
//  BandSearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import Foundation

class BandSearchViewModel: ObservableObject {
    @Published var fetchedBands = [Band]()
    @Published var searchText = ""
    
    @MainActor
    func getBands(withSearchText searchText: String) async throws {
        fetchedBands = try await DatabaseService.shared.searchForBands(name: searchText)
    }
}
