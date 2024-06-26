//
//  PaymasterClientTests.swift
//
//
//  Created by Frederic DE MATOS on 21/06/2024.
//

import XCTest
import web3
import BigInt
@testable import swift4337


class PaymasterClientTests: XCTestCase {
    let paymaster = TestPaymasterClient()
    
    override func setUp(){
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSponsorUserOperationIsOk() async throws {
        
        let userOp = UserOperation(sender: "0x2FF46F26638977AE8C88e205cCa407A1a9725F0B",
                                   nonce: "0x05",
                                   callData: "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000", preVerificationGas: "0xef1c", callGasLimit: "0x163a2",
                                   verificationGasLimit: "0x1b247",
                                   maxFeePerGas: "0x01e3fb094e",
                                   maxPriorityFeePerGas: "0x53cd81aa"
        )
        
        let sponsorResponse = try await self.paymaster.pm_sponsorUserOperation(userOp, entryPoint: EthereumAddress(SafeConfig.entryPointV7().entryPointAddress))
        XCTAssertEqual(sponsorResponse?.paymasterAndData, "0xDFF7FA1077Bce740a6a212b3995990682c0Ba66d000000000000000000000000000000000000000000000000000000006672ce7100000000000000000000000000000000000000000000000000000000000000000e499f53c85c53cd4f1444b807e380c6a01a412d7e1cfd24b6153debb97cbc986e6809dff8c005ed94c32bf1d5e722b9f40b909fc89d8982f2f99cb7a91b19f01c" )
       
        XCTAssertEqual(sponsorResponse?.preVerificationGas, "0xef1c" )
        XCTAssertEqual(sponsorResponse?.verificationGasLimit, "0x1b247" )
    }
    
    
    func testSupportedEntryPointsIsOk() async throws {
        let entrypoints = try await self.paymaster.pm_supportedEntryPoints()
        XCTAssertEqual(entrypoints[0].toChecksumAddress(), SafeConfig.entryPointV7().entryPointAddress )
    }
}
