//
//  SmartAccountProtocolTests.swift
//  
//
//  Created by Frederic DE MATOS on 21/06/2024.
//

import XCTest
import web3
import BigInt
@testable import swift4337

class SmartAccountProtocolTests: XCTestCase {
    var smartAccount: SmartAccountProtocol!
    let rpc = TestRPCClient(network: EthereumNetwork.sepolia)
    let bundler = TestBundlerClient()
    let paymaster = TestPaymasterClient()
    let account = try! EthereumAccount.init(keyStorage: TestEthereumKeyStorage(privateKey: "0x4646464646464646464646464646464646464646464646464646464646464646"))
    
    override func setUp(){
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testGetNonceIsOk() async throws {
        self.smartAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        let expected = BigUInt(5);
        
        let nonce = try await self.smartAccount.getNonce()
        XCTAssertEqual(nonce, expected)
    }
    
    
    func testIsDeployedWithDeployedReturnTrueIsOk() async throws {
        self.smartAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        let isDeployed = try await self.smartAccount.isDeployed()
        let expected = true;
        
        XCTAssertEqual(isDeployed, expected)
    }
    
    func testIsDeployedWithNotDeployedReturnFalseIsOk() async throws {
        self.smartAccount = try await SafeAccount(address: EthereumAddress("0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E"), signer: account, rpc: rpc, bundler: bundler)
        let isDeployed = try await self.smartAccount.isDeployed()
        let expected = false;
        
        XCTAssertEqual(isDeployed, expected)
        
    }
    
    func testPrepareUserOperationWithAccountDeployedIsOk() async throws {
        self.smartAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        
        let userOperation = try await self.smartAccount.prepareUserOperation(to: EthereumAddress("0x0338Dcd5512ae8F3c481c33Eb4b6eEdF632D1d2f"), value: BigUInt(0), data: "0x06661abd".web3.hexData!)
        
        XCTAssertEqual(userOperation.sender, "0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2" )
        XCTAssertEqual(userOperation.callGasLimit, "12100" )
        XCTAssertEqual(userOperation.preVerificationGas, "60460" )
        XCTAssertEqual(userOperation.verificationGasLimit, "285642" )
        XCTAssertEqual(userOperation.maxFeePerGas, "0x01e3fb094e" )
        XCTAssertEqual(userOperation.maxPriorityFeePerGas, "0x53cd81aa" )
      //  XCTAssertEqual(userOperation.paymasterAndData, "0x" )
        XCTAssertEqual(userOperation.callData, "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000" )
        XCTAssertEqual(userOperation.factory, nil )
        XCTAssertEqual(userOperation.factoryData, nil )
        XCTAssertEqual(userOperation.getInitCode(), "0x" )
        XCTAssertEqual(userOperation.nonce, "0x05" )
        XCTAssertEqual(userOperation.signature, "0x000000000000000000000000" )
    }
    
    func testPrepareUserOperationWithAccountDeployedAndValueAndNoDataIsOk() async throws {
        self.smartAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler)
        
        let userOperation = try await self.smartAccount.prepareUserOperation(to: EthereumAddress("0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E"), value: BigUInt(1))
        
        XCTAssertEqual(userOperation.sender, "0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2" )
        XCTAssertEqual(userOperation.callGasLimit, "12100" )
        XCTAssertEqual(userOperation.preVerificationGas, "60460" )
        XCTAssertEqual(userOperation.verificationGasLimit, "285642" )
        XCTAssertEqual(userOperation.maxFeePerGas, "0x01e3fb094e" )
        XCTAssertEqual(userOperation.maxPriorityFeePerGas, "0x53cd81aa" )
     //   XCTAssertEqual(userOperation.paymasterAndData, "0x" )
        XCTAssertEqual(userOperation.callData, "0x7bb37428000000000000000000000000f64da4efa19b42ef2f897a3d533294b892e6d99e0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" )
        XCTAssertEqual(userOperation.factory, nil )
        XCTAssertEqual(userOperation.factoryData, nil )
        XCTAssertEqual(userOperation.nonce, "0x05" )
        XCTAssertEqual(userOperation.signature, "0x000000000000000000000000" )
    }
    
    func testPrepareUserOperationWithAccountNotDeployedIsOk() async throws {
        self.smartAccount = try await SafeAccount(address: EthereumAddress("0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E"), signer: account, rpc: rpc, bundler: bundler)
        
        let userOperation = try await self.smartAccount.prepareUserOperation(to: EthereumAddress("0x0338Dcd5512ae8F3c481c33Eb4b6eEdF632D1d2f"), data: "0x06661abd".web3.hexData!)
        
        XCTAssertEqual(userOperation.sender, "0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E" )
        XCTAssertEqual(userOperation.callGasLimit, "12100" )
        XCTAssertEqual(userOperation.preVerificationGas, "60460" )
        XCTAssertEqual(userOperation.verificationGasLimit, "285642" )
        XCTAssertEqual(userOperation.maxFeePerGas, "0x01e3fb094e" )
        XCTAssertEqual(userOperation.maxPriorityFeePerGas, "0x53cd81aa" )
       // XCTAssertEqual(userOperation.paymasterAndData, "0x" )
        XCTAssertEqual(userOperation.callData, "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000" )
        XCTAssertEqual(userOperation.factory, "0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67")
        XCTAssertEqual(userOperation.factoryData, "0x1688f0b900000000000000000000000029fcb43b46531bca003ddc8fcb67ffe91900c7620000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e4b63e800d000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002dd68b007b46fbe91b9a7c3eda5a7a1063cb5b47000000000000000000000000000000000000000000000000000000000000014000000000000000000000000075cf11467937ce3f2f357ce24ffc3dbf8fd5c22600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000009d8a62f656a8d1615c1294fd71e9cfb3e4855a4f00000000000000000000000000000000000000000000000000000000000000648d0dc49f0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000075cf11467937ce3f2f357ce24ffc3dbf8fd5c2260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertEqual(userOperation.getInitCode(), "0x4e1dcf7ad4e460cfd30791ccc4f9c8a4f820ec671688f0b900000000000000000000000029fcb43b46531bca003ddc8fcb67ffe91900c7620000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e4b63e800d000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002dd68b007b46fbe91b9a7c3eda5a7a1063cb5b47000000000000000000000000000000000000000000000000000000000000014000000000000000000000000075cf11467937ce3f2f357ce24ffc3dbf8fd5c22600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000009d8a62f656a8d1615c1294fd71e9cfb3e4855a4f00000000000000000000000000000000000000000000000000000000000000648d0dc49f0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000075cf11467937ce3f2f357ce24ffc3dbf8fd5c2260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" )
        XCTAssertEqual(userOperation.nonce, "0x05" )
        XCTAssertEqual(userOperation.signature, "0x000000000000000000000000")
    }
    
    func testPrepareUserOperationWithAccountPaymasterIsOk() async throws {
        self.smartAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler, paymaster: paymaster)
        
        let userOperation = try await self.smartAccount.prepareUserOperation(to: EthereumAddress("0x0338Dcd5512ae8F3c481c33Eb4b6eEdF632D1d2f"), value: BigUInt(0), data: "0x06661abd".web3.hexData!)
        
        XCTAssertEqual(userOperation.sender, "0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2" )
        XCTAssertEqual(userOperation.callGasLimit, "0x16270" )
        XCTAssertEqual(userOperation.preVerificationGas, "0xd8a1" )
        XCTAssertEqual(userOperation.verificationGasLimit, "0x8146c" )
        XCTAssertEqual(userOperation.paymaster, "0x4685d9587a7F72Da32dc323bfFF17627aa632C61" )
        XCTAssertEqual(userOperation.paymasterData, "0x00000000000000000000000000000000000000000000000000000000667d1421000000000000000000000000000000000000000000000000000000000000000026e7da98c314096d74cd7fb9d2e3bf074e20dd71f91ab6e9b7c0ad4d4ac057f15ad0d942b6880daddbf9d0ff9791c05ff64528f3428c3d4f3ee45cb5c12250081c" )
        XCTAssertEqual(userOperation.paymasterPostOpGasLimit, "0x1" )
        XCTAssertEqual(userOperation.paymasterVerificationGasLimit, "0x4e09" )
        
        
        XCTAssertEqual(userOperation.maxFeePerGas, "0x01e3fb094e" )
        XCTAssertEqual(userOperation.maxPriorityFeePerGas, "0x53cd81aa" )
      //  XCTAssertEqual(userOperation.paymasterAndData, "0xDFF7FA1077Bce740a6a212b3995990682c0Ba66d000000000000000000000000000000000000000000000000000000006672ce7100000000000000000000000000000000000000000000000000000000000000000e499f53c85c53cd4f1444b807e380c6a01a412d7e1cfd24b6153debb97cbc986e6809dff8c005ed94c32bf1d5e722b9f40b909fc89d8982f2f99cb7a91b19f01c" )
        XCTAssertEqual(userOperation.callData, "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000" )
        XCTAssertEqual(userOperation.factory, nil )
        XCTAssertEqual(userOperation.factoryData, nil )
        XCTAssertEqual(userOperation.nonce, "0x05" )
        XCTAssertEqual(userOperation.signature, "0x000000000000000000000000" )
    }
    
    func testSendUserOperationIsOk() async throws {
        self.smartAccount = try await SafeAccount(signer: account, rpc: rpc, bundler: bundler, paymaster: paymaster)
        
        let userOperationHash = try await self.smartAccount.sendUserOperation(to: EthereumAddress("0x0338Dcd5512ae8F3c481c33Eb4b6eEdF632D1d2f"), value: BigUInt(0), data: "0x06661abd".web3.hexData!)
        
        XCTAssertEqual(userOperationHash, "0xb38a2faf4b5c716eff634af472206f28574cd5104c69d97a315c3303ddb5fdbd" )
    }
}
