//
//  File.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import web3
import swift4337

enum TestBundlerClientError: Error {
    case notImplemented

}

struct TestBundlerClient: BundlerClientProtocol{
    
    
    func eth_sendUserOperation(_ userOperation: swift4337.UserOperation, entryPoint: web3.EthereumAddress) async throws -> String {
        throw TestBundlerClientError.notImplemented
    }
    
    func eth_estimateUserOperationGas(_ userOperation: swift4337.UserOperation, entryPoint: web3.EthereumAddress) async throws -> swift4337.UserOperationGasEstimationResponse {
        throw TestBundlerClientError.notImplemented
    }
    
    func eth_getUserOperationByHash(_ userOperationHash: String) async throws -> swift4337.GetUserOperationByHashResponse? {
        throw TestBundlerClientError.notImplemented
    }
    
    func eth_getUserOperationReceipt(_ userOperationHash: String) async throws -> swift4337.GetUserOperationReceiptResponse? {
        throw TestBundlerClientError.notImplemented
    }
    
    func eth_supportedEntryPoints() async throws -> [web3.EthereumAddress] {
        throw TestBundlerClientError.notImplemented
    }
}
