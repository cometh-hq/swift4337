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
            let sponsoredResponse = SponsorUserOperationResponse(paymasterAndData: "0xDFF7FA1077Bce740a6a212b3995990682c0Ba66d000000000000000000000000000000000000000000000000000000006672ce7100000000000000000000000000000000000000000000000000000000000000000e499f53c85c53cd4f1444b807e380c6a01a412d7e1cfd24b6153debb97cbc986e6809dff8c005ed94c32bf1d5e722b9f40b909fc89d8982f2f99cb7a91b19f01c", preVerificationGas: "0xef1c", verificationGasLimit: "0x1b247", callGasLimit: "0x163a2")
            
            return sponsoredResponse
        }
        
        if (method == "eth_estimateUserOperationGas") {
            let userOpEstimation = UserOperationGasEstimationResponse(preVerificationGas: "60460",
                                                                     verificationGasLimit: "285642",
                                                                     callGasLimit: "12100")
            return userOpEstimation
         
        }
        
        if (method == "eth_sendUserOperation") {
            let param = (params as! [AnyEncodable])[0]
             
             guard let encoded = try? JSONEncoder().encode(param) else {
                 throw JSONRPCError.encodingError
             }
            
            if let result = try? JSONDecoder().decode(UserOperation.self, from: encoded) {
                guard result.signature == "0x0000000000000000000000004232f7414022b3da2b1b3fc2d82d40a10eefc29c913c6801c1827dcb1c3735c8065234a4435ec0ca3a13786ecd683320661a5abb2b1dd2c2b3fc8dcf1473fcd81c" else {
                    throw TestNetworkProviderError.unexpectedValue
                }
                
                return "0xb38a2faf4b5c716eff634af472206f28574cd5104c69d97a315c3303ddb5fdbd"
            }
            
            throw TestNetworkProviderError.unexpectedValue
        }
        
        if (method == "eth_feeHistory") {
            let feeHistory =  FeeHistoryResponse(oldestBlock: "0x531c",
                                               reward: [
                                                [
                                                    "0x155a4548"
                                                ],
                                                [
                                                    "0x59682f00"
                                                ],
                                                [
                                                    "0x3b9aca00"
                                                ],
                                                [
                                                    "0x59682f00"
                                                ],
                                                [
                                                    "0x59682f00"
                                                ]
                                            ], baseFeePerGas:  [
                                                "0xc876a5b8",
                                                "0xc5b2834c",
                                                "0xbb3a432a",
                                                "0xc3f3bbac",
                                                "0xc6617c5e",
                                                "0xc816c3d2"
                                            ], gasUsedRatio:  [
                                                0.4448049,
                                                0.2881665,
                                                0.6863933666666666,
                                                0.5495778666666666,
                                                0.5344412666666667
                                            ])
            
            return feeHistory
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
