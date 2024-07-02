//
//  BundlerClientProtocol.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import Foundation
import web3
import os

public struct Log: Decodable {
    public let logIndex: String
    public let transactionIndex: String
    public let transactionHash: String
    public let blockHash: String
    public let blockNumber: String
    public let address: String
    public let data: String
    public let topics: [String]
    
    public init(logIndex: String, transactionIndex: String, transactionHash: String, blockHash: String, blockNumber: String, address: String, data: String, topics: [String]) {
        self.logIndex = logIndex
        self.transactionIndex = transactionIndex
        self.transactionHash = transactionHash
        self.blockHash = blockHash
        self.blockNumber = blockNumber
        self.address = address
        self.data = data
        self.topics = topics
    }
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
    public let effectiveGasPrice: String?
    public let cumulativeGasUsed: String?
    
    public init(transactionHash: String, transactionIndex: String, blockHash: String, blockNumber: String, from: String, to: String, gasUsed: String, contractAddress: String?, logs: [Log], logsBloom: String, status: String, effectiveGasPrice: String?, cumulativeGasUsed: String?) {
        self.transactionHash = transactionHash
        self.transactionIndex = transactionIndex
        self.blockHash = blockHash
        self.blockNumber = blockNumber
        self.from = from
        self.to = to
        self.gasUsed = gasUsed
        self.contractAddress = contractAddress
        self.logs = logs
        self.logsBloom = logsBloom
        self.status = status
        self.effectiveGasPrice = effectiveGasPrice
        self.cumulativeGasUsed = cumulativeGasUsed
    }
}

public struct GetUserOperationReceiptResponse: Decodable{
    public let userOpHash: String
    public let sender: String
    public let nonce: String
    public let actualGasUsed: String
    public let paymaster: String?
    public let actualGasCost: String
    public let success: Bool
    public let logs: [Log]
    public let receipt: Receipt
    
    public init(userOpHash: String, sender: String, nonce: String, actualGasUsed: String, paymaster: String?, actualGasCost: String, success: Bool, logs: [Log], receipt: Receipt) {
        self.userOpHash = userOpHash
        self.sender = sender
        self.nonce = nonce
        self.actualGasUsed = actualGasUsed
        self.paymaster = paymaster
        self.actualGasCost = actualGasCost
        self.success = success
        self.logs = logs
        self.receipt = receipt
    }
}

public struct GetUserOperationByHashResponse: Decodable{
    public let userOperation: UserOperation
    public let entryPoint: String
    public let transactionHash: String?
    public let blockHash: String?
    public let blockNumber: String?
    
    public init(userOperation: UserOperation, entryPoint: String, transactionHash: String, blockHash: String, blockNumber: String) {
        self.userOperation = userOperation
        self.entryPoint = entryPoint
        self.transactionHash = transactionHash
        self.blockHash = blockHash
        self.blockNumber = blockNumber
    }
}


public struct UserOperationGasEstimationResponse:Decodable {
    public let preVerificationGas: String
    public let verificationGasLimit: String
    public let callGasLimit: String
    
    public init(preVerificationGas: String, verificationGasLimit: String, callGasLimit: String) {
        self.preVerificationGas = preVerificationGas
        self.verificationGasLimit = verificationGasLimit
        self.callGasLimit = callGasLimit
    }
}


public protocol BundlerClientProtocol: JSONRPCClientProtocol {
     func eth_sendUserOperation(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> String
     func eth_estimateUserOperationGas(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> UserOperationGasEstimationResponse
     func eth_getUserOperationByHash(_ userOperationHash: String)  async throws -> GetUserOperationByHashResponse?
     func eth_getUserOperationReceipt(_ userOperationHash: String)  async throws -> GetUserOperationReceiptResponse?
     func eth_supportedEntryPoints ()  async throws -> [EthereumAddress] 
}

public extension BundlerClientProtocol {
    
    func eth_sendUserOperation(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> String {
        let params: [AnyEncodable] = [AnyEncodable(userOperation), AnyEncodable(entryPoint.toChecksumAddress())]
        
        do {
            let data = try await self.networkProvider.send(method: "eth_sendUserOperation", params: params, receive: String.self)
            
            if let userOperationHash = data as? String {
                return userOperationHash
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            Logger.defaultLogger.error("eth_sendUserOperation error")
            throw failureHandler(error)
        }
    }
    
    
    func eth_estimateUserOperationGas(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> UserOperationGasEstimationResponse {
        let params: [AnyEncodable] = [AnyEncodable(userOperation), AnyEncodable(entryPoint.toChecksumAddress())]
        
        do {
            let data = try await  self.networkProvider.send(method: "eth_estimateUserOperationGas", params: params, receive: UserOperationGasEstimationResponse.self)
            
            if let estimation = data as? UserOperationGasEstimationResponse {
                return estimation
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            Logger.defaultLogger.error("eth_estimateUserOperationGas error")
            throw failureHandler(error)
        }
    }
    
    
    func eth_getUserOperationByHash(_ userOperationHash: String)  async throws -> GetUserOperationByHashResponse? {
        let params: [AnyEncodable] = [AnyEncodable(userOperationHash)]
        
        do {
            let data = try await self.networkProvider.send(method: "eth_getUserOperationByHash", params: params, receive: GetUserOperationByHashResponse?.self)
            
            if let userOperationHash = data as? GetUserOperationByHashResponse? {
                return userOperationHash
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            Logger.defaultLogger.error("eth_getUserOperationByHash error")
            throw failureHandler(error)
        }
    }
    
    func eth_getUserOperationReceipt(_ userOperationHash: String)  async throws -> GetUserOperationReceiptResponse? {
        let params: [AnyEncodable] = [AnyEncodable(userOperationHash)]
        
        do {
            let data = try await self.networkProvider.send(method: "eth_getUserOperationReceipt", params: params, receive: GetUserOperationReceiptResponse?.self)
            
            if let userOperationHash = data as? GetUserOperationReceiptResponse? {
                return userOperationHash
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            Logger.defaultLogger.error("eth_getUserOperationReceipt error")
            throw failureHandler(error)
        }
    }
    
    
    func eth_supportedEntryPoints ()  async throws -> [EthereumAddress] {
        let params: [AnyEncodable] = []
        
        do {
            let data = try await  self.networkProvider.send(method: "eth_supportedEntryPoints", params: params, receive: [EthereumAddress].self)
            
            if let estimation = data as? [EthereumAddress] {
                return estimation
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            Logger.defaultLogger.error("eth_supportedEntryPoints error")
            throw failureHandler(error)
        }
    }
}
