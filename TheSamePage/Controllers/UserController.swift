//
//  UserViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class UserController: ObservableObject {
    enum UserControllerError: Error {
        case firestoreError(message: String)
        case firebaseAuthError(message: String)
    }
    
    // TODO: Clear these values when user signs out
    @Published var createdBand: Band?
    

    
}
