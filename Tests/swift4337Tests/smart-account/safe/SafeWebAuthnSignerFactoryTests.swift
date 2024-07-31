//
//  SafeWebAuthnSignerFactoryTests.swift
//
//
//  Created by Frederic DE MATOS on 29/07/2024.
//

import XCTest
import web3
import BigInt
@testable import swift4337

class SafeWebAuthnSignerFactoryTests: XCTestCase {
    
    func testEncodeGetSignerIsOk() async throws {
        let config = SafeConfig.entryPointV7()
        let verifiers = EthereumAddress(config.safeP256VerifierAddress).asNumber()!
             
             
        let x = BigUInt(hex: "0x3628C66B9BA2B579E51E6B7DDCBF7526C0B882678655BDE48A7BB1504662A362")!
        let y = BigUInt(hex: "0x9F4304A01B5B94BCEC32D29DAB08F3ABC5E305AE05FB953D0372BCB7E752ECC")!
        
        let getSignerFunction = GetSignerFunction(contract:  EthereumAddress(config.safeWebauthnSignerFactory), x: x, y: y, verifiers: verifiers)
        
        let expected = "0xa541d91a3628c66b9ba2b579e51e6b7ddcbf7526c0b882678655bde48a7bb1504662a36209f4304a01b5b94bcec32d29dab08f3abc5e305ae05fb953d0372bcb7e752ecc000000000000000000000000445a0683e494ea0c5af3e83c5159fbe47cf9e765"
        
        XCTAssertEqual(try getSignerFunction.transaction().data!.web3.hexString, expected)
        
    }
    
    func testEncodeGetSigner2IsOk() async throws {
        let config = SafeConfig.entryPointV7()
    
             
             
        let x = BigUInt(hex: "0xe0161e5c76f0c4dfa580102899ad0e82b2cb3be0329ec1ae9abb0aa878d4dd3a")!
        let y = BigUInt(hex: "0xeafbeb6a97b5c782fc3abdf0c61d6576047988420bd38d7b0cd22493e77c35a7")!
        let verifiers = BigUInt("375087029821578385695419886245161665007891705074112")
        
        let getSignerFunction = GetSignerFunction(contract:  EthereumAddress(config.safeWebauthnSignerFactory), x: x, y: y, verifiers: verifiers)
        
        let expected = "0xa541d91ae0161e5c76f0c4dfa580102899ad0e82b2cb3be0329ec1ae9abb0aa878d4dd3aeafbeb6a97b5c782fc3abdf0c61d6576047988420bd38d7b0cd22493e77c35a7000000000000000000000100a51c1fc2f0d1a1b8494ed1fe312d7c3a78ed91c0"
        
        XCTAssertEqual(try getSignerFunction.transaction().data!.web3.hexString, expected)
        
    }

    
    func testEncodeCreateSignerIsOk() async throws {
        let config = SafeConfig.entryPointV7()
        let verifiers = EthereumAddress(config.safeP256VerifierAddress).asNumber()!
             
        let x = BigUInt(hex: "0x3628C66B9BA2B579E51E6B7DDCBF7526C0B882678655BDE48A7BB1504662A362")!
        let y = BigUInt(hex: "0x9F4304A01B5B94BCEC32D29DAB08F3ABC5E305AE05FB953D0372BCB7E752ECC")!
        
        let createSignerFunction = CreateSignerFunction(contract: EthereumAddress(config.safeWebauthnSignerFactory), x: x, y: y, verifiers: verifiers)
        
        let expected = "0x0d2f04893628c66b9ba2b579e51e6b7ddcbf7526c0b882678655bde48a7bb1504662a36209f4304a01b5b94bcec32d29dab08f3abc5e305ae05fb953d0372bcb7e752ecc000000000000000000000000445a0683e494ea0c5af3e83c5159fbe47cf9e765"
        
        XCTAssertEqual(try createSignerFunction.transaction().data!.web3.hexString, expected)
        
    }
}
