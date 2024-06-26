//
//  BundlerClientTests.swift
//
//
//  Created by Frederic DE MATOS on 21/06/2024.
//
import XCTest
import web3
import BigInt
@testable import swift4337

class BundlerClientTests: XCTestCase {
    let bundler = TestBundlerClient()
    
    let userOp = UserOperation(sender: "0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2",
                               nonce: "0x05",
                               callData: "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000", preVerificationGas: "0xef1c", callGasLimit: "0x163a2",
                               verificationGasLimit: "0x1b247",
                               maxFeePerGas: "0x01e3fb094e",
                               maxPriorityFeePerGas: "0x53cd81aa",
                               signature: "0x00000000000000000000000049451b90ec9fe697058863e768db59acf362a28ad6d01ac4146f6f77a3670981327ff5ec9662672375f8a4dec525fd513dee129350935c4a2af75d4e7e27a21f1c")
    
    override func setUp(){
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSupportedEntryPointsIsOk() async throws {
        let entrypoints = try await self.bundler.eth_supportedEntryPoints()
        XCTAssertEqual(entrypoints[0].toChecksumAddress(), SafeConfig.entryPointV7().entryPointAddress )
    }
    
    func testEstimateUserOperationGasIsOk() async throws {

        let userOperationestimation = try await self.bundler.eth_estimateUserOperationGas(self.userOp, entryPoint: EthereumAddress(SafeConfig.entryPointV7().entryPointAddress))
        XCTAssertEqual(userOperationestimation.callGasLimit, "12100" )
        XCTAssertEqual(userOperationestimation.preVerificationGas, "60460" )
        XCTAssertEqual(userOperationestimation.verificationGasLimit, "285642" )
    }
    
    func testSendUserOperationIsOk() async throws {
        let userOperationHash = try await self.bundler.eth_sendUserOperation(self.userOp, entryPoint: EthereumAddress(SafeConfig.entryPointV7().entryPointAddress))
        XCTAssertEqual(userOperationHash, "0xb38a2faf4b5c716eff634af472206f28574cd5104c69d97a315c3303ddb5fdbd" )
    }
    
    func testGetUserOperationByHashIsOk() async throws {
        let response = try await self.bundler.eth_getUserOperationByHash("0xb38a2faf4b5c716eff634af472206f28574cd5104c69d97a315c3303ddb5fdbd")
       
        XCTAssertEqual(response?.entryPoint, SafeConfig.entryPointV7().entryPointAddress)
        XCTAssertEqual(response?.transactionHash, "0x87004b8eda9e46071f0feb28ffb32a94d9475edb76000102bca104cc78a14291")
        XCTAssertEqual(response?.blockHash, "0x505de34521e76be46c6f6c28ca939e75708375a12e74abc8f043916f4a4b01d5" )
        XCTAssertEqual(response?.blockNumber, "0x5d99da" )
        
        let userOperation = response!.userOperation
        
        XCTAssertEqual(userOperation.sender, "0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2" )
        XCTAssertEqual(userOperation.callGasLimit, "0x163a2" )
        XCTAssertEqual(userOperation.preVerificationGas, "0xef1c" )
        XCTAssertEqual(userOperation.verificationGasLimit, "0x1b247" )
        XCTAssertEqual(userOperation.maxFeePerGas, "0x01e3fb094e" )
        XCTAssertEqual(userOperation.maxPriorityFeePerGas, "0x53cd81aa" )
        XCTAssertEqual(userOperation.paymasterAndData, "0x" )
        XCTAssertEqual(userOperation.callData, "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000" )
        XCTAssertEqual(userOperation.factory, nil )
        XCTAssertEqual(userOperation.factoryData, nil )
        XCTAssertEqual(userOperation.nonce, "0x05" )
        XCTAssertEqual(userOperation.signature, "0x00000000000000000000000049451b90ec9fe697058863e768db59acf362a28ad6d01ac4146f6f77a3670981327ff5ec9662672375f8a4dec525fd513dee129350935c4a2af75d4e7e27a21f1c" )
    }
    
    
    func testGetUserOperationReceipIsOk() async throws {
        let response = try await self.bundler.eth_getUserOperationReceipt("0xb38a2faf4b5c716eff634af472206f28574cd5104c69d97a315c3303ddb5fdbd")
        
        
        XCTAssertEqual(response?.userOpHash, "0xb38a2faf4b5c716eff634af472206f28574cd5104c69d97a315c3303ddb5fdbd")
        XCTAssertEqual(response?.sender, "0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2")
        XCTAssertEqual(response?.nonce, "0x05" )
        XCTAssertEqual(response?.paymaster, "0xDFF7FA1077Bce740a6a212b3995990682c0Ba66d" )
        XCTAssertEqual(response?.actualGasUsed, "0x27708" )
        XCTAssertEqual(response?.actualGasCost, "0x2430233b9e2a0" )
        XCTAssertEqual(response?.success, true )
        
        XCTAssertEqual(response?.logs.count, 1)
        
        let log = response?.logs[0]
        
        XCTAssertEqual(log?.logIndex, "0x75")
        XCTAssertEqual(log?.transactionIndex, "0x3c")
        XCTAssertEqual(log?.transactionHash, "0xeb5c691c133d39fe58ff86f7c21ad86b038f0c4e0e5f0df45b01df583967dc6c" )
        XCTAssertEqual(log?.blockHash, "0x3ee65e562607df56a086f527272c1637961deb5205223125b613296a0326fe17" )
        XCTAssertEqual(log?.blockNumber, "0x5dc7bd" )
        XCTAssertEqual(log?.address, "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789" )
        XCTAssertEqual(log?.data, "0x" )
        XCTAssertEqual(log?.topics[0], "0xbb47ee3e183a558b1a2ff0874b079f3fc5478b7454eacf2bfc5af2ff5878f972")
        
        let receipt = response?.receipt
        
        XCTAssertEqual(receipt?.transactionHash, "0xeb5c691c133d39fe58ff86f7c21ad86b038f0c4e0e5f0df45b01df583967dc6c")
        XCTAssertEqual(receipt?.transactionIndex, "0x3c")
        XCTAssertEqual(receipt?.blockHash, "0x3ee65e562607df56a086f527272c1637961deb5205223125b613296a0326fe17" )
        XCTAssertEqual(receipt?.blockNumber, "0x5dc7bd" )
        XCTAssertEqual(receipt?.from, "0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E" )
        XCTAssertEqual(receipt?.to, "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789" )
        XCTAssertEqual(receipt?.cumulativeGasUsed, "0x21089")
        XCTAssertEqual(receipt?.gasUsed, "0xfc539b")
        XCTAssertEqual(receipt?.logs.count, 1)
        XCTAssertEqual(receipt?.logsBloom, "0x00000000000040000000000000000000000000000000000000000000000000800008000000000000000200010000000000100000000020000000020000000000000000000000000000000000000000000000000000000000000000000040000000000000080000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000040000000000000000000000000000000000008000400000000000000000000000000000000002000000000000000020000000000001000000000000000000000000000000000000000000000000002001000000000000000000000000000000000000040000000000000000")
        XCTAssertEqual(receipt?.status, "0x1")
        XCTAssertEqual(receipt?.effectiveGasPrice, "0x2d977b")
        
    }
}
