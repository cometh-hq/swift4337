//
//  RPCGasEstimatorTests.swift
//  
//
//  Created by Frederic DE MATOS on 21/06/2024.
//

import XCTest
import web3
import BigInt
@testable import swift4337


class RPCGasEstimatorTests: XCTestCase {
    let gasEstimator = RPCGasEstimator(TestRPCClient(network: EthereumNetwork.sepolia))
    
    override func setUp(){
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testGetGasFeesWithBaseMultiplier100AndPriorityMultiplier100IsOK() async throws {
        let gasEstimator = RPCGasEstimator(TestRPCClient(network: EthereumNetwork.sepolia), baseFeePercentMultiplier: 100, priorityFeePercentMultiplier: 100)
        let gasFee = try await gasEstimator.getGasFees()
        
        // (0x155a4548 + 0x59682f00 + 0x3b9aca00 + 0x59682f00 + 0x59682f00) / 5
        XCTAssertEqual(gasFee.maxPriorityFeePerGas, BigUInt(1171647502))
        XCTAssertEqual(gasFee.maxFeePerGas, BigUInt(hex: "0xc816c3d2")! + gasFee.maxPriorityFeePerGas)
    }
    
    func testGetGasFeesWithDefautReturnBaseTime2AndPriorityTimeOnePoint2IsOK() async throws {
        let gasEstimator = RPCGasEstimator(TestRPCClient(network: EthereumNetwork.sepolia))
        let gasFee = try await gasEstimator.getGasFees()
        
        // (0x155a4548 + 0x59682f00 + 0x3b9aca00 + 0x59682f00 + 0x59682f00) / 5 * 1.2
        XCTAssertEqual(gasFee.maxPriorityFeePerGas, BigUInt(1405977002).multiplied(by: BigUInt(120).quotientAndRemainder(dividingBy: BigUInt(100)).quotient))
        
        XCTAssertEqual(gasFee.maxFeePerGas,
                       BigUInt(hex: "0xc816c3d2")!.multiplied(by: BigUInt(2)) + gasFee.maxPriorityFeePerGas)
    }
    
    
    func testGetGasFeesWithMinBaseFeeIsOK() async throws {
        let gasEstimator = RPCGasEstimator(TestRPCClient(network: EthereumNetwork.sepolia), minBaseFee: BigUInt(300000000000))
        let gasFee = try await gasEstimator.getGasFees()
        
        // (0x155a4548 + 0x59682f00 + 0x3b9aca00 + 0x59682f00 + 0x59682f00) / 5 * 1.2
        XCTAssertEqual(gasFee.maxPriorityFeePerGas, BigUInt(1405977002).multiplied(by: BigUInt(120).quotientAndRemainder(dividingBy: BigUInt(100)).quotient))
        
        XCTAssertEqual(gasFee.maxFeePerGas,
                       BigUInt(300000000000))
    }
    
    func testGetGasFeesWithMinPriorityFeeIsOK() async throws {
        let gasEstimator = RPCGasEstimator(TestRPCClient(network: EthereumNetwork.sepolia), minPriorityFee: BigUInt(2000000000))
        let gasFee = try await gasEstimator.getGasFees()
        
        XCTAssertEqual(gasFee.maxPriorityFeePerGas, BigUInt(2000000000))
        
        XCTAssertEqual(gasFee.maxFeePerGas,
                       BigUInt(hex: "0xc816c3d2")!.multiplied(by: BigUInt(2)) + gasFee.maxPriorityFeePerGas)
    }
    
    
}
