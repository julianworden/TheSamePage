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

    /// The information that the view is supposed to be displaying has been deleted. Setting this view state will usually
    /// dismiss a view.  For example, BandProfileView should dismiss itself when it was displaying info for a band that
    /// was deleted via BandSettingsView.
    case dataDeleted
    
    case error(message: String)
}
