//
//  ABIEncoderBigUIntTests.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import XCTest
import web3
import BigInt
@testable import swift4337


class ABIEncoderBigUIntTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEncodeBigUIntWith256SizeIsOk() throws {
        let value = BigUInt(299)
        let size = 256
        let expected =  "0x000000000000000000000000000000000000000000000000000000000000012b";
        
        let result = try ABIEncoder.encode(value, uintSize:size)
        XCTAssertEqual(result.hexString, expected)
    }
    
    func testEncodeBigUIntWith48SizeIsOk() throws {
        let value = BigUInt(299)
        let size = 48
        let expected =  "0x00000000012b";
        
        let result = try ABIEncoder.encode(value, uintSize:size)
        XCTAssertEqual(result.hexString, expected)
    }
    
    func testEncodeBigUIntWithSizeTooSmallThrows() throws {
        let value = BigUInt(299)
        let size = 2
        
        XCTAssertThrowsError( try ABIEncoder.encode(value, uintSize:size)) {
            error in
            XCTAssertEqual(error as! ABIError, ABIError.invalidValue)
        }
    }

}
