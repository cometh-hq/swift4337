//
//  PaymasterProtocol.swift
//
//
//  Created by Frederic DE MATOS on 20/06/2024.
//
import Foundation
import web3


public struct SponsorUserOperationResponse: Decodable{
    public let paymaster: String
    public let paymasterData: String
    public let paymasterVerificationGasLimit: String
    public let paymasterPostOpGasLimit: String
    public let callGasLimit: String?
    public let preVerificationGas: String?
    public let verificationGasLimit:  String?
    
    public init(paymaster: String, paymasterData: String, paymasterVerificationGasLimit: String, paymasterPostOpGasLimit: String, callGasLimit: String? = nil, preVerificationGas: String? = nil, verificationGasLimit: String? = nil) {
        self.paymaster = paymaster
        self.paymasterData = paymasterData
        self.paymasterVerificationGasLimit = paymasterVerificationGasLimit
        self.paymasterPostOpGasLimit = paymasterPostOpGasLimit
        
        self.preVerificationGas = preVerificationGas
        self.verificationGasLimit = verificationGasLimit
        self.callGasLimit = callGasLimit
    }
}

public protocol PaymasterClientProtocol: JSONRPCClientProtocol {    
    func pm_sponsorUserOperation(_ userOperation: UserOperation, entryPoint: EthereumAddress) async throws -> SponsorUserOperationResponse?
    func pm_supportedEntryPoints()  async throws -> [EthereumAddress]
}


public extension PaymasterClientProtocol{
     
    func pm_sponsorUserOperation(_ userOperation: UserOperation, entryPoint: EthereumAddress)  async throws -> SponsorUserOperationResponse? {
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
    
    func pm_supportedEntryPoints()  async throws -> [EthereumAddress] {
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

