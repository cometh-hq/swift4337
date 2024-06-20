//
//  UInt8ArrayExtensionsTests.swift.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import XCTest
@testable import swift4337



class UInt8ArrayExtensionsTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUint8ArrayKeccack256Case1IsOk() throws {
        let value = "0x6080604052348015600f57600080fd5b5060405160e338038060e38339818101604052810190602d9190604c565b80600081905550506097565b6000815190506046816083565b92915050565b600060208284031215605f57605e607e565b5b6000606b848285016039565b91505092915050565b6000819050919050565b600080fd5b608a816074565b8114609457600080fd5b50565b603f8060a46000396000f3fe6080604052600080fdfea2646970667358221220a32ca22663d59fb69eed5207435acdbbb7af0b9c8b4e7a096fddadb2ad231a5e64736f6c63430008070033582df9c679de47d035351d9fd580f77c04bdf36d8270e95ba1fa01ef64dc2568".web3.bytesFromHex!
        let expected = "0x44436c1b46a02af854be0490f564348d0d496483b3f6f7a9acc797d34c2cecef"
        
        XCTAssertEqual(value.keccak256.web3.hexString, expected)
    }
    
    func testUint8ArrayKeccack256Case2IsOk() throws {
        let value = "0xff4e1dcf7ad4e460cfd30791ccc4f9c8a4f820ec67dd4357ab477d47899a4976c44762fb59931767bbf890f6be804e42a975c49cb8e298282cefe913ab5d282047161268a8222e4bd4ed106300c547894bbefd31ee".web3.bytesFromHex!
        let expected = "0x35f36f48a038fb91d493554a2142dd0e494701e2e2d4660c63569f510e3a7df8"
        
        XCTAssertEqual(value.keccak256.web3.hexString, expected)
    }
    
    func testUint8ArrayHexStringIsOk() throws {
        let value = "0xff4e1dcf7ad4e460cfd30791ccc4f9c8a4f820ec67dd4357ab477d47899a4976c44762fb59931767bbf890f6be804e42a975c49cb8e298282cefe913ab5d282047161268a8222e4bd4ed106300c547894bbefd31ee"
        
        XCTAssertEqual(value.web3.bytesFromHex!.hexString, value)
    }
    
    func testUint8ArraySliceIsOk() throws {
        let value = "0x35f36f48a038fb91d493554a2142dd0e494701e2e2d4660c63569f510e3a7df8".web3.bytesFromHex!
        
        XCTAssertEqual(value.slice(12).hexString, "0x2142dd0e494701e2e2d4660c63569f510e3a7df8")
    }
}
     
