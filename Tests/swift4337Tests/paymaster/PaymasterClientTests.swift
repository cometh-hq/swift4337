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
   
        XCTAssertEqual(sponsorResponse?.paymaster, "0x4685d9587a7F72Da32dc323bfFF17627aa632C61" )
        XCTAssertEqual(sponsorResponse?.paymasterData, "0x00000000000000000000000000000000000000000000000000000000667d1421000000000000000000000000000000000000000000000000000000000000000026e7da98c314096d74cd7fb9d2e3bf074e20dd71f91ab6e9b7c0ad4d4ac057f15ad0d942b6880daddbf9d0ff9791c05ff64528f3428c3d4f3ee45cb5c12250081c" )
        XCTAssertEqual(sponsorResponse?.paymasterPostOpGasLimit, "0x1" )
        XCTAssertEqual(sponsorResponse?.paymasterVerificationGasLimit, "0x4e09" )
        
        XCTAssertEqual(sponsorResponse?.preVerificationGas, "0xd8a1" )
        XCTAssertEqual(sponsorResponse?.verificationGasLimit, "0x8146c" )
    }
    
    
    func testSupportedEntryPointsIsOk() async throws {
        let entrypoints = try await self.paymaster.pm_supportedEntryPoints()
        XCTAssertEqual(entrypoints[0].toChecksumAddress(), SafeConfig.entryPointV7().entryPointAddress )
    }
}
