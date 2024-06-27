//
//  TestNetworkProvider.swift
//
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import Foundation
import web3
import swift4337
import BigInt
import os

enum TestNetworkProviderError: Error {
    case unexpectedValue
}


class TestNetworkProvider: NetworkProviderProtocol {
    var session: URLSession
    
    func send<P, U>(method: String, params: P, receive: U.Type) async throws -> Any where P : Encodable, U : Decodable {
        if (method == "eth_getCode"){
            if (params as! [String])[0] == "0xf64da4efa19b42ef2f897a3d533294b892e6d99e"  {
                return "0x"
            } else {
                return "0x1"
            }
        }
        
        if (method == "pm_sponsorUserOperation") {
            return TestDataUtils.sponsorUserOperationResponse
        }
        
        if (method == "pm_supportedEntryPoints" || method == "eth_supportedEntryPoints") {
            return [EthereumAddress(SafeConfig.entryPointV7().entryPointAddress)]
        }

        if (method == "eth_estimateUserOperationGas") {
            return TestDataUtils.userOperationGasEstimationResponse
        }
        
        if (method == "eth_getUserOperationReceipt") {
            return  TestDataUtils.getUserOperationReceiptResponse
        }
        
        if (method == "eth_getUserOperationByHash") {
            return TestDataUtils.getUserOperationByHashResponse
        }
        
        if (method == "eth_sendUserOperation") {
            let param = (params as! [AnyEncodable])[0]
             
             guard let encoded = try? JSONEncoder().encode(param) else {
                 throw JSONRPCError.encodingError
             }
            
            if let result = try? JSONDecoder().decode(UserOperation.self, from: encoded) {
               
                guard result.signature == "0x000000000000000000000000f3b1844e8b4e5ce91db47894f7d60e5dc043f7b363f467c727442c7d4b1d8a1f1d1ce48574862154d61e2f144be579669b68e0fb08d25039648e3d6d5b75257c1c" else {
                    throw TestNetworkProviderError.unexpectedValue
                }
                
                return "0xb38a2faf4b5c716eff634af472206f28574cd5104c69d97a315c3303ddb5fdbd"
            }
            
            throw TestNetworkProviderError.unexpectedValue
        }
        
        if (method == "eth_feeHistory") {
            return TestDataUtils.feeHistoryResponse
        }
        
        throw TestRPCClientError.notImplemented
    }
    
    init() {
        let networkQueue = OperationQueue()
        networkQueue.name = "test.client.networkQueue"
        networkQueue.maxConcurrentOperationCount = 4
        let session = URLSession(configuration:URLSession.shared.configuration, delegate: nil, delegateQueue: networkQueue)
        
        self.session = session
    }
    
}
