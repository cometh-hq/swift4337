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
        
        if (method == "pm_supportedEntryPoints" || method == "eth_supportedEntryPoints") {
            return [EthereumAddress(SafeConfig().entryPointAddress)]
        }

        if (method == "eth_estimateUserOperationGas") {
            let userOpEstimation = UserOperationGasEstimationResponse(preVerificationGas: "60460",
                                                                     verificationGasLimit: "285642",
                                                                     callGasLimit: "12100")
            return userOpEstimation
         
        }
        
        if (method == "eth_getUserOperationReceipt") {
            let log = Log(logIndex: "0x75",
                          transactionIndex: "0x3c",
                          transactionHash: "0xeb5c691c133d39fe58ff86f7c21ad86b038f0c4e0e5f0df45b01df583967dc6c",
                          blockHash: "0x3ee65e562607df56a086f527272c1637961deb5205223125b613296a0326fe17",
                          blockNumber: "0x5dc7bd",
                          address: "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789",
                          data:  "0x",
                          topics: ["0xbb47ee3e183a558b1a2ff0874b079f3fc5478b7454eacf2bfc5af2ff5878f972"])
            
            
          
            
            let receipt = Receipt(transactionHash:  "0xeb5c691c133d39fe58ff86f7c21ad86b038f0c4e0e5f0df45b01df583967dc6c",
                                  transactionIndex: "0x3c",
                                  blockHash: "0x3ee65e562607df56a086f527272c1637961deb5205223125b613296a0326fe17",
                                  blockNumber: "0x5dc7bd" ,
                                  from: "0xF64DA4EFa19b42ef2f897a3D533294b892e6d99E",
                                  to: "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789" ,
                                  gasUsed: "0xfc539b",
                                  contractAddress: nil,
                                  logs: [log],
                                  logsBloom: "0x00000000000040000000000000000000000000000000000000000000000000800008000000000000000200010000000000100000000020000000020000000000000000000000000000000000000000000000000000000000000000000040000000000000080000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000040000000000000000000000000000000000008000400000000000000000000000000000000002000000000000000020000000000001000000000000000000000000000000000000000000000000002001000000000000000000000000000000000000040000000000000000",
                                  status: "0x1",
                                  effectiveGasPrice: "0x2d977b",
                                  cumulativeGasUsed: "0x21089")
            
            return GetUserOperationReceiptResponse(userOpHash: "0xb38a2faf4b5c716eff634af472206f28574cd5104c69d97a315c3303ddb5fdbd",
                                                   sender: "0x2FF46F26638977AE8C88e205cCa407A1a9725F0B",
                                                   nonce: "0x05",
                                                   actualGasUsed: "0x27708",
                                                   paymaster: "0xDFF7FA1077Bce740a6a212b3995990682c0Ba66d",
                                                   actualGasCost: "0x2430233b9e2a0",
                                                   success: true,
                                                   logs: [log],
                                                   receipt: receipt)
            
        }
        
        if (method == "eth_getUserOperationByHash") {
            
            return GetUserOperationByHashResponse(userOperation: UserOperation(sender: "0x2FF46F26638977AE8C88e205cCa407A1a9725F0B",
                                                                                       nonce: "0x05",
                                                                                       initCode: "0x",
                                                                                       callData: "0x7bb374280000000000000000000000000338dcd5512ae8f3c481c33eb4b6eedf632d1d2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000406661abd00000000000000000000000000000000000000000000000000000000", preVerificationGas: "0xef1c", callGasLimit: "0x163a2",
                                                                                       verificationGasLimit: "0x1b247",
                                                                                       maxFeePerGas: "0x01e3fb094e",
                                                                                       maxPriorityFeePerGas: "0x53cd81aa",
                                                                                       signature: "0x0000000000000000000000004232f7414022b3da2b1b3fc2d82d40a10eefc29c913c6801c1827dcb1c3735c8065234a4435ec0ca3a13786ecd683320661a5abb2b1dd2c2b3fc8dcf1473fcd81c"),
                                                          entryPoint: SafeConfig().entryPointAddress,
                                                          transactionHash: "0x87004b8eda9e46071f0feb28ffb32a94d9475edb76000102bca104cc78a14291",
                                                          blockHash: "0x505de34521e76be46c6f6c28ca939e75708375a12e74abc8f043916f4a4b01d5",
                                                          blockNumber: "0x5d99da")
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
