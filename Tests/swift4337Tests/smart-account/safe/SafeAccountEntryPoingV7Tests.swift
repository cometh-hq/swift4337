//
//  SafeAccountEntryPoingV7Tests.swift
//
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import XCTest
import web3
import BigInt
@testable import swift4337


  

class SafeAccountEntryPoingV7Tests: XCTestCase {
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
        let safeConfig = SafeConfig.entryPointV7()
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler, safeConfig:safeConfig)
        let expectedAddress = EthereumAddress("0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2")
        
         XCTAssertEqual(safeAccount.address.toChecksumAddress(), expectedAddress.toChecksumAddress())
    }
    
    

    
    func testSignUserOperationIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler, safeConfig: SafeConfig.entryPointV7())
        let userOp = UserOperation(sender: "0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2",
                                   nonce: "0x00",
                                   callData: "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000",
                                   preVerificationGas:"0xea60",
                                   callGasLimit: "0x1e8480",
                                   verificationGasLimit: "0x07a120", maxFeePerGas:"0x02ee7c55e2",
                                   maxPriorityFeePerGas: "0x1f2ecf7f",
                                   paymasterAndData:"0x")
                                   
        
        let expected = "0x000000000000000000000000298adde4bafae7cf44a9bf2a1881a836716592c85ac5f6445e673647d6cc907e3af6d065c591f07173e83246ef649147b0034bf119da693c4025be55206e9db91c"
        let signature = try  self.safeAccount.signUserOperation(userOp)
        
        XCTAssertEqual(signature.web3.hexString, expected)
    }
    
}
