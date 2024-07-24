//
//  TalkALotTests.swift
//  TalkALotTests
//
//  Created by Otto Willborn on 2024-07-23.
//

import XCTest
import Firebase
@testable import TalkALot

final class SignUpViewTest: XCTestCase {
    var signUpValidator: SignUpValidator!

    override func setUp() {
        super.setUp()
        signUpValidator = SignUpValidator()
        
        // Clear UserDefaults for a clean test environment
        UserDefaults.standard.removeObject(forKey: "signIn")
    }

    override func tearDown() {
        signUpValidator = nil
        super.tearDown()
    }

    func testInvalidEmail() {
        let result = signUpValidator.validate(email: "invalidemail", password: "password123", confirmPassword: "password123")
        XCTAssertTrue(result.isShowingError)
        XCTAssertEqual(result.errorMessage, "Email is poorly formatted")
    }
    
    func testShortPassword() {
        let result = signUpValidator.validate(email: "test@example.com", password: "short", confirmPassword: "short")
        XCTAssertTrue(result.isShowingError)
        XCTAssertEqual(result.errorMessage, "Password must be at least 8 characters long")
    }

    func testPasswordsNotMatching() {
        let result = signUpValidator.validate(email: "test@example.com", password: "password123", confirmPassword: "differentPassword")
        XCTAssertTrue(result.isShowingError)
        XCTAssertEqual(result.errorMessage, "Passwords do not match")
    }
    
    func testValidSignUp() {
        let result = signUpValidator.validate(email: "test@example.com", password: "password1234", confirmPassword: "password1234")
        XCTAssertFalse(result.isShowingError)
        
        // Check UserDefaults for sign-in status
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "signIn"))
    }
}


