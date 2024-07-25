//
//  LogInViewTest.swift
//  TalkALotTests
//
//  Created by Otto Willborn on 2024-07-24.
//

import XCTest
import Firebase
import GoogleSignIn
@testable import TalkALot

final class LogInViewTest: XCTestCase {
    var logInValidator: LogInValidator!
    
    override func setUp() {
        super.setUp()
        logInValidator = LogInValidator()
        
        // Clear UserDefaults for a clean test environment
        UserDefaults.standard.removeObject(forKey: "signIn")
    }
    
    override func tearDown() {
        logInValidator = nil
        super.tearDown()
    }
    
    func testInvalidEmail() {
        let result = logInValidator.validate(email: "invalidemail", password: "password123")
        XCTAssertTrue(result)
    }
    
    func testShortPassword() {
        let result = logInValidator.validate(email: "test@example.com", password: "short")
        XCTAssertTrue(result)
    }
}
