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
        
        let expected = "0x5bb4e6e63628c66b9ba2b579e51e6b7ddcbf7526c0b882678655bde48a7bb1504662a36209f4304a01b5b94bcec32d29dab08f3abc5e305ae05fb953d0372bcb7e752ecc000000000000000000000000445a0683e494ea0c5af3e83c5159fbe47cf9e765"
        
        XCTAssertEqual(try getSignerFunction.transaction().data!.web3.hexString, expected)
        
    }
    
    func testEncodeCreateSignerIsOk() async throws {
        let config = SafeConfig.entryPointV7()
        let verifiers = EthereumAddress(config.safeP256VerifierAddress).asNumber()!
             
        let x = BigUInt(hex: "0x3628C66B9BA2B579E51E6B7DDCBF7526C0B882678655BDE48A7BB1504662A362")!
        let y = BigUInt(hex: "0x9F4304A01B5B94BCEC32D29DAB08F3ABC5E305AE05FB953D0372BCB7E752ECC")!
        
        let createSignerFunction = CreateSignerFunction(contract: EthereumAddress(config.safeWebauthnSignerFactory), x: x, y: y, verifiers: verifiers)
        
        let expected = "0x26a53db83628c66b9ba2b579e51e6b7ddcbf7526c0b882678655bde48a7bb1504662a36209f4304a01b5b94bcec32d29dab08f3abc5e305ae05fb953d0372bcb7e752ecc000000000000000000000000445a0683e494ea0c5af3e83c5159fbe47cf9e765"
        
        XCTAssertEqual(try createSignerFunction.transaction().data!.web3.hexString, expected)
        
    }
}
