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
    
    func testGetGasFeesIsOK() async throws {
        let gasFee = try await gasEstimator.getGasFees()
        XCTAssertEqual(gasFee.maxFeePerGas, BigUInt(8119847246))
        XCTAssertEqual(gasFee.maxPriorityFeePerGas, BigUInt(1405977002))
    }
}
