//
//  PaymasterProtocol.swift
//
//
//  Created by Frederic DE MATOS on 20/06/2024.
//
import Foundation
import web3

public struct SponsorUserOperationResponse: Decodable{
    public let paymasterAndData: String
    public let preVerificationGas: String
    public let verificationGasLimit:  String
    public let callGasLimit: String
}

public protocol PaymasterClientProtocol {    
    func pm_sponsorUserOperation(_ userOperation: UserOperation, entryPoint: EthereumAddress) async throws -> SponsorUserOperationResponse?
    func pm_supportedEntryPoints()  async throws -> [EthereumAddress]
}


