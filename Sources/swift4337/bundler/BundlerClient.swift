//
//  BundlerClient.swift
//  
//
//  Created by Frederic DE MATOS on 12/06/2024.
//

import Foundation
import web3
import os

open class BundlerClient: JSONRPCClient, BundlerClientProtocol {
    
    public func eth_sendUserOperation(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> String {
        let params: [AnyEncodable] = [AnyEncodable(userOperation), AnyEncodable(entryPoint.toChecksumAddress())]
    
        do {
            let data = try await self.networkProvider.send(method: "eth_sendUserOperation", params: params, receive: String.self)
        
            if let userOperationHash = data as? String {
                return userOperationHash
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    
    public func eth_estimateUserOperationGas(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> UserOperationGasEstimationResponse {
        let params: [AnyEncodable] = [AnyEncodable(userOperation), AnyEncodable(entryPoint.toChecksumAddress())]
    
        do {
            let data = try await  self.networkProvider.send(method: "eth_estimateUserOperationGas", params: params, receive: UserOperationGasEstimationResponse.self)
        
            if let estimation = data as? UserOperationGasEstimationResponse {
                return estimation
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    
    public func eth_getUserOperationByHash(_ userOperationHash: String)  async throws -> GetUserOperationByHashResponse? {
        let params: [AnyEncodable] = [AnyEncodable(userOperationHash)]
    
        do {
            let data = try await self.networkProvider.send(method: "eth_getUserOperationByHash", params: params, receive: GetUserOperationByHashResponse?.self)
        
            if let userOperationHash = data as? GetUserOperationByHashResponse? {
                return userOperationHash
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    public func eth_getUserOperationReceipt(_ userOperationHash: String)  async throws -> GetUserOperationReceiptResponse? {
        let params: [AnyEncodable] = [AnyEncodable(userOperationHash)]
    
        do {
            let data = try await self.networkProvider.send(method: "eth_getUserOperationReceipt", params: params, receive: GetUserOperationReceiptResponse?.self)
        
            if let userOperationHash = data as? GetUserOperationReceiptResponse? {
                return userOperationHash
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    public func eth_supportedEntryPoints ()  async throws -> [EthereumAddress] {
        let params: [AnyEncodable] = []
    
        do {
            let data = try await  self.networkProvider.send(method: "eth_supportedEntryPoints", params: params, receive: [EthereumAddress].self)
        
            if let estimation = data as? [EthereumAddress] {
                return estimation
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
}
