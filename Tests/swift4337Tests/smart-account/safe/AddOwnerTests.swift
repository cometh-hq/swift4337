//
//  AddOwnerTests.swift
//  
//
//  Created by Frederic DE MATOS on 29/07/2024.
//


import XCTest
import web3
import BigInt
@testable import swift4337

class AddOwnerTests: XCTestCase {
    
    func testEncodeAddOwnerWithThresholdIsOk() async throws {
        let newOwner  = EthereumAddress("0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E")
        let threshold = BigUInt(1)
        
        let addOwnerWithThresholdFunction =  AddOwnerWithThresholdFunction(contract: EthereumAddress.zero, owner: newOwner, _threshold: threshold)
        let expected = "0x0d582f13000000000000000000000000f64da4efa19b42ef2f897a3d533294b892e6d99e0000000000000000000000000000000000000000000000000000000000000001"
        
        XCTAssertEqual(try addOwnerWithThresholdFunction.transaction().data!.web3.hexString, expected)
        
    }
}
