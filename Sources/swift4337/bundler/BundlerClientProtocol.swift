//
//  BundlerClientProtocol.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import Foundation
import web3

public struct Log: Decodable {
    public let logIndex: String
    public let transactionIndex: String
    public let transactionHash: String
    public let blockHash: String
    public let blockNumber: String
    public let address: String
    public let data: String
    public let topics: [String]
}

public struct Receipt: Decodable {
    public let transactionHash: String
    public let transactionIndex: String
    public let blockHash: String
    public let blockNumber: String
    public let from: String
    public let to: String
    public let gasUsed: String
    public let contractAddress: String?
    public let logs: [Log]
    public let logsBloom: String
    public let status: String
    public let effectiveGasPrice: String
}

public struct GetUserOperationReceiptResponse: Decodable{
    public let userOpHash: String
    public let sender: String
    public let nonce: String
    public let actualGasUsed: String
    public let actualGasCost: String
    public let success: Bool
    public let logs: [Log]
    public let receipt: Receipt
}

public struct GetUserOperationByHashResponse: Decodable{
    public let userOperation: UserOperation
    public let entryPoint: String
    public let transactionHash: String
    public let blockHash: String
    public let blockNumber: String
}


public struct UserOperationGasEstimationResponse:Decodable {
    public let preVerificationGas: String
    public let verificationGasLimit: String
    public let callGasLimit: String
}


public protocol BundlerClientProtocol {
     func eth_sendUserOperation(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> String
     func eth_estimateUserOperationGas(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> UserOperationGasEstimationResponse
     func eth_getUserOperationByHash(_ userOperationHash: String)  async throws -> GetUserOperationByHashResponse?
     func eth_getUserOperationReceipt(_ userOperationHash: String)  async throws -> GetUserOperationReceiptResponse?
     func eth_supportedEntryPoints ()  async throws -> [EthereumAddress] 
}
