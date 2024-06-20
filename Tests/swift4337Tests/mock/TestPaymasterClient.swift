//
//  File.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//


import web3
import swift4337

enum TestPaymasterClientError: Error {
    case notImplemented

}

struct TestPaymasterClient: PaymasterClientProtocol{
    func pm_sponsorUserOperation(_ userOperation: swift4337.UserOperation, entryPoint: web3.EthereumAddress) async throws -> swift4337.SponsorUserOperationResponse? {
        throw TestBundlerClientError.notImplemented
    }
    
    func pm_supportedEntryPoints() async throws -> [web3.EthereumAddress] {
        throw TestBundlerClientError.notImplemented
    }
    
}
