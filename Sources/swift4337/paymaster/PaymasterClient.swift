//
//  PaymasterClient.swift
//  
//
//  Created by Frederic DE MATOS on 19/06/2024.
//

import Foundation
import web3



open class PaymasterClient: JSONRPCClient, PaymasterClientProtocol {
    
    public func pm_sponsorUserOperation(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> SponsorUserOperationResponse? {
        let params: [AnyEncodable] = [AnyEncodable(userOperation), AnyEncodable(entryPoint.toChecksumAddress())]
    
        do {
            let data = try await  self.networkProvider.send(method: "pm_sponsorUserOperation", params: params, receive: SponsorUserOperationResponse?.self)
        
            if let estimation = data as? SponsorUserOperationResponse? {
                return estimation
            } else {
                throw EthereumClientError.unexpectedReturnValue
            }
        } catch {
            throw failureHandler(error)
        }
    }
    
    public func pm_supportedEntryPoints()  async throws -> [EthereumAddress] {
        let params: [AnyEncodable] = []
    
        do {
            let data = try await  self.networkProvider.send(method: "pm_supportedEntryPoints", params: params, receive: [EthereumAddress].self)
        
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
