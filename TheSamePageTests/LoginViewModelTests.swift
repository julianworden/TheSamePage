//
//  LoginViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 11/15/22.
//

@testable import TheSamePage
import XCTest

final class LoginViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEmailAddressIsEmpty() throws {
        let sut = LoginViewModel()
        
        XCTAssertEqual(sut.emailAddress, "")
    }
    
    func testLogInFunctionWorks() async throws {
        let sut = LoginViewModel()
        
        try await sut.logInButtonTapped(emailAddress: "julianworden@gmail.com", password: "dynomite")
        
        XCTAssertTrue(sut.loginButtonIsDisabled)
        XCTAssertFalse(sut.loginErrorShowing)
        XCTAssertEqual(sut.loginErrorMessage, "")
    }
}
