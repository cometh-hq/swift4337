//
//  SafeAccountEntryPoingV6Tests.swift
//
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import XCTest
import web3
import BigInt
@testable import swift4337


  

class SafeAccountEntryPoingV6Tests: XCTestCase {
    var safeAccount: SafeAccount!
    let rpc = TestRPCClient(network: EthereumNetwork.sepolia)
    let bundler = TestBundlerClient()
    let account = try! EthereumAccount.init(keyStorage: TestEthereumKeyStorage(privateKey: "0x4646464646464646464646464646464646464646464646464646464646464646"))
  
    override func setUp(){
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitWalletWithoutAddressProdictAddressIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        let expectedAddress = EthereumAddress("0x2ff46f26638977ae8c88e205cca407a1a9725f0b")
        
         XCTAssertEqual(safeAccount.address.toChecksumAddress(), expectedAddress.toChecksumAddress())
    }
    
    func testSignUserOperationIsOk() async throws {
        
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        let userOp = UserOperation(sender: "0x2ff46f26638977ae8c88e205cca407a1a9725f0b",
                                   nonce: "0x00",
                                   callData: "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000",
                                   preVerificationGas:"0xea60",
                                   callGasLimit: "0x1e8480",
                                   verificationGasLimit: "0x07a120", maxFeePerGas:"0x02ee7c55e2",
                                   maxPriorityFeePerGas: "0x1f2ecf7f",
                                   paymasterAndData:"0x")
                                   
        
        let expected = "0x000000000000000000000000a5927f1a1d8783d9d7033abf5f1883582525a3558055b46a9425c5627a1a83d460d64f361379e3aa710d74b3c4763288598f373c866263c4a45394908c74a6d31c"
        
        let signature = try  self.safeAccount.signUserOperation(userOp)
        
        XCTAssertEqual(signature.web3.hexString, expected)
    }
}
