//
//  ViewState.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/14/22.
//

import Foundation

enum ViewState: Equatable {
    /// View that does not rely on any asynchronous work is being displayed.
    case displayingView
    
    /// Work that's usually asynchronous that was triggered by the user is being performed.
    /// For example, used when the Create Show button is tapped.
    case performingWork
    
    /// Work that's usually asynchronous that was triggered by the user has completed. For example,
    /// used after a show has been successfully created.
    case workCompleted
    
    /// Asynchronous work is being performed that was not triggered by a gesture from the user. For example,
    /// used when fetching shows in HomeView.
    case dataLoading
    
    /// Asynchronous work that was not triggered by  by a gesture from the user has finished. For example,
    /// shows in HomeView have been fetched.
    case dataLoaded
    
    /// Asynchronous work that was not triggered by  by a gesture from the user failed to fetch results. For example,
    /// no shows are found in the user's area in HomeView.
    case dataNotFound
    
    case error(message: String)
}
