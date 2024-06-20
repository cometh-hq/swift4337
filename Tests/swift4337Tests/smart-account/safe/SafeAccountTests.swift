//
//  SafeAccountTests.swift.swift
//
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import XCTest
import web3
import BigInt
@testable import swift4337

let testPrivateKey = "0x4646464646464646464646464646464646464646464646464646464646464646";
  

class SafeAccountTests: XCTestCase {
    var safeAccount: SafeAccount!
    let rpc = TestRPCClient(network: EthereumNetwork.sepolia)
    let bundler = TestBundlerClient()
    let account = try! EthereumAccount.init(keyStorage: TestEthereumKeyStorage(privateKey: "0x4646464646464646464646464646464646464646464646464646464646464646"))
    // let rpc  = EthereumHttpClient(url: URL(string: "https://sepolia.infura.io/v3/2416b322dddc49d0806a64b11cfe423b")!, network: EthereumNetwork.sepolia)
    // let resut = try await rpc.eth_call(EthereumTransaction(to: EthereumAddress("0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67"), data: "0x53e5d935".web3.hexData!))
  
    
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
    
    func testGetCallDataIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        let callData = try safeAccount.getCallData(to: EthereumAddress("0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E"), value: BigUInt(1), data: "0x".web3.hexData!)
        
        let expected = "0x7bb37428000000000000000000000000f64da4efa19b42ef2f897a3d533294b892e6d99e0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        
         XCTAssertEqual(callData, expected)
    }
    
}
