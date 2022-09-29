//
//  BandSearchViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import Foundation

class BandSearchViewModel: ObservableObject {
    @Published var fetchedResults = [AnySearchable]()
    @Published var searchText = ""
    
    @MainActor
    func getBands() async throws {
        fetchedResults = try await DatabaseService.shared.performSearch(for: .band, withName: searchText)
    }
}
