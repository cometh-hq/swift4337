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
    let account = try! EthereumAccount.init(keyStorage: TestEthereumKeyStorage(privateKey: "0x4646464646464646464646464646464646464646464646464646464646464646")).toSigner()
  
    override func setUp(){
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitWalletWithoutAddressPredictAddressIsOk() async throws {
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
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
                                   maxPriorityFeePerGas: "0x1f2ecf7f", signature: "0x")
                                   
        
        let expected = "0x000000000000000000000000298adde4bafae7cf44a9bf2a1881a836716592c85ac5f6445e673647d6cc907e3af6d065c591f07173e83246ef649147b0034bf119da693c4025be55206e9db91c"
        let signature = try await self.safeAccount.signUserOperation(userOp)
        
        XCTAssertEqual(signature.web3.hexString, expected)
    }
    
    func testInitWalletWithoutAddressProdictAddressWithCustomSafeConfigIsOk() async throws {
        var safeConfig = SafeConfig.entryPointV7()
        safeConfig.creationNonce = BigUInt(2)
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler, safeConfig:safeConfig)
        let expectedAddress = EthereumAddress("0x03d5Fb2d95cE2Aeb329C247DC4D10f2D7AB07679")
        
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
        let expected = "0x1688f0b900000000000000000000000029fcb43b46531bca003ddc8fcb67ffe91900c7620000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e4b63e800d000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002dd68b007b46fbe91b9a7c3eda5a7a1063cb5b47000000000000000000000000000000000000000000000000000000000000014000000000000000000000000075cf11467937ce3f2f357ce24ffc3dbf8fd5c22600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000009d8a62f656a8d1615c1294fd71e9cfb3e4855a4f00000000000000000000000000000000000000000000000000000000000000648d0dc49f0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000075cf11467937ce3f2f357ce24ffc3dbf8fd5c2260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        
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
    
    
    func testInitWalletWithCustomGasEstimatorIsOk() async throws {
      
        let gasEstimator = RPCGasEstimator(rpc, minBaseFee: BigUInt(50000000))
        self.safeAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler, gasEstimator: gasEstimator)
       
        XCTAssertEqual(safeAccount.gasEstimator.minBaseFee, BigUInt(50000000))
    }
}
