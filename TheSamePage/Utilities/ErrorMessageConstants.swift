//
//  Constants.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/17/22.
//

import Foundation

struct ErrorMessageConstants {
    static let unknownError = "An unknown error occurred, please try again"
    static let checkYourConnection = "Please confirm you have an internet connection"
    static let invalidViewState = "Invalid ViewState."
    static let incompleteForm = "The form is incomplete. Please ensure you've filled all the required fields."
    static let deviceIsOffline = "NOTE: Your device is not connected to the internet"
    static let emptyChatMessage = "You cannot send an empty message."
    static let invalidEmailAddress = "Please enter a valid email address."

    // MARK: Sign In
    static let networkErrorOnSignIn = "Login failed. \(checkYourConnection)"
    static let wrongPasswordOnSignIn = "Incorrect email or password. Please try again."
    static let userNotFoundOnSignIn = "This email address is not registered with The Same Page. If you need to create a new account, use the Sign Up button."

    // MARK: - Forgot Password
    static let emailAddressDoesNotBelongToAccountOnForgotPassword = "This email address is not associated with an existing account on The Same Page. If you need to create an account, go back and tap the Sign Up button."

    // MARK: Sign Up
    static let incompleteFormOnSignUp = "Incomplete form. Please enter your first and last name."
    static let invalidOrMissingEmailOnSignUp = "Please enter a valid email address."
    static let emailAlreadyInUseOnSignUp = "An account with this email address already exists, please go back and sign in or reset your password, if necessary."
    static let networkErrorOnSignUp = "Sign up failed. \(checkYourConnection)"
    static let weakPasswordOnSignUp = "Please enter a valid password, it must be 6 characters long or more."

    // MARK: SendShowInvite
    static let bandIsAlreadyPlayingShow = "This band is already playing this show."
    static let showLineupIsFull = "This show's lineup is full. To invite this band, either increase the show's max number of bands or remove a band from the show's lineup."
}
