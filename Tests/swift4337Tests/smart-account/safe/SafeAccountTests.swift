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


  

class SafeAccountTests: XCTestCase {
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
    
    func testInitWalletWithoutAddressProdictAddressWithCustomSafeConfigIsOk() async throws {
        var safeConfig = SafeConfig.entryPointV6()
        safeConfig.creationNonce = BigUInt(2)
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler, safeConfig:safeConfig)
        let expectedAddress = EthereumAddress("0x2bEB15C8994C9C7b6cc6C70220Cf81381f5CC385")
        
         XCTAssertEqual(safeAccount.address.toChecksumAddress(), expectedAddress.toChecksumAddress())
    }

    func testGetCallDataWithOnlyValueIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        let callData = try safeAccount.getCallData(to: EthereumAddress("0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E"), value: BigUInt(1), data: "0x".web3.hexData!)
        
        let expected = "0x7bb37428000000000000000000000000f64da4efa19b42ef2f897a3d533294b892e6d99e0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        
        XCTAssertEqual(callData.web3.hexString, expected)
    }
    
    func testGetCallDataWithDataIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        let callData = try safeAccount.getCallData(to: EthereumAddress("0x0338Dcd5512ae8F3c481c33Eb4b6eEdF632D1d2f"), value: BigUInt(0), data: "0x06661abd".web3.hexData!)
        
        let expected = "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000"
        
        XCTAssertEqual(callData.web3.hexString, expected)
    }
    
    
    func testGetFactoryAddressIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        
        XCTAssertEqual(self.safeAccount.getFactoryAddress(), EthereumAddress(self.safeAccount.safeConfig.proxyFactory))
    }
    
    
    func testGetFactoryDataIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        let factoryData = try await self.safeAccount.getFactoryData()
        let expected = "0x1688f0b900000000000000000000000029fcb43b46531bca003ddc8fcb67ffe91900c7620000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e4b63e800d000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002dd68b007b46fbe91b9a7c3eda5a7a1063cb5b470000000000000000000000000000000000000000000000000000000000000140000000000000000000000000a581c4a4db7175302464ff3c06380bc3270b403700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000009d8a62f656a8d1615c1294fd71e9cfb3e4855a4f00000000000000000000000000000000000000000000000000000000000000648d0dc49f00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a581c4a4db7175302464ff3c06380bc3270b40370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        
        XCTAssertEqual(factoryData.web3.hexString, expected)
    }
    
    
    
    func testGetOwnerWithNotDeployedThrows() async throws {
        self.safeAccount = try await SafeAccount(address: EthereumAddress("0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E"), signer: account, rpc: rpc, bundler: bundler)
        
        do{
            _ = try await self.safeAccount.getOwners()
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as! SmartAccountError, SmartAccountError.errorAccountNotDeployed)
        }
    }
    
    func testGetOwnerWithDeployedIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        
        let owners = try await self.safeAccount.getOwners()
        XCTAssertEqual(owners[0].toChecksumAddress(), account.address.toChecksumAddress())
    }
}
