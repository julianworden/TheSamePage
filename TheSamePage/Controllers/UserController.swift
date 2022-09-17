//
//  UserViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import Foundation

class UserController: ObservableObject {
    @Published var bands = [Band]()
    
    func getBands() {
        bands = User.example.bands ?? []
    }
}
