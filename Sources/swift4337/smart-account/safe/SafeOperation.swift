//
//  SafeOperation.swift
//
//
//  Created by Frederic DE MATOS on 26/06/2024.
//

import Foundation
import web3
import BigInt


struct SafeOperation {
    
     static let EIP712_SAFE_OPERATION_TYPE_V2 = """
                         "SafeOp":[
                            {
                               "type":"address",
                               "name":"safe"
                            },
                            {
                               "type":"uint256",
                               "name":"nonce"
                            },
                            {
                               "type":"bytes",
                               "name":"initCode"
                            },
                            {
                               "type":"bytes",
                               "name":"callData"
                            },
                            {
                               "type":"uint256",
                               "name":"callGasLimit"
                            },
                            {
                               "type":"uint256",
                               "name":"verificationGasLimit"
                            },
                            {
                               "type":"uint256",
                               "name":"preVerificationGas"
                            },
                            {
                               "type":"uint256",
                               "name":"maxFeePerGas"
                            },
                            {
                               "type":"uint256",
                               "name":"maxPriorityFeePerGas"
                            },
                            {
                               "type":"bytes",
                               "name":"paymasterAndData"
                            },
                            {
                               "type":"uint48",
                               "name":"validAfter"
                            },
                            {
                               "type":"uint48",
                               "name":"validUntil"
                            },
                            {
                               "type":"address",
                               "name":"entryPoint"
                            }
                         ]
        """
    
    static let EIP712_SAFE_OPERATION_TYPE_V3 = """
                        "SafeOp":[
                           {
                              "type":"address",
                              "name":"safe"
                           },
                           {
                              "type":"uint256",
                              "name":"nonce"
                           },
                           {
                              "type":"bytes",
                              "name":"initCode"
                           },
                           {
                              "type":"bytes",
                              "name":"callData"
                           },
                           {
                              "type":"uint128",
                              "name":"verificationGasLimit"
                           },
                           {
                              "type":"uint128",
                              "name":"callGasLimit"
                           },
                           {
                              "type":"uint256",
                              "name":"preVerificationGas"
                           },
                           {
                              "type":"uint128",
                              "name":"maxPriorityFeePerGas"
                           },
                           {
                              "type":"uint128",
                              "name":"maxFeePerGas"
                           },
                           {
                              "type":"bytes",
                              "name":"paymasterAndData"
                           },
                           {
                              "type":"uint48",
                              "name":"validAfter"
                           },
                           {
                              "type":"uint48",
                              "name":"validUntil"
                           },
                           {
                              "type":"address",
                              "name":"entryPoint"
                           }
                        ]
       """
    
    static func eip712Data(domain: EIP712Domain, userOperation: UserOperation, validUntil: BigUInt, validAfter: BigUInt, entryPointAddress: EthereumAddress, entryPointVersion:EntryPointVersion)-> Data {
        
        let safeOperationType: String
            
        switch(entryPointVersion){
        case .V6:
            safeOperationType = EIP712_SAFE_OPERATION_TYPE_V2
            
        case .V7:
            safeOperationType = EIP712_SAFE_OPERATION_TYPE_V3
        }
       
        let jsonData = """
           {
              "types":{
                 "EIP712Domain":[
                    {
                       "name":"chainId",
                       "type":"uint256"
                    },
                    {
                       "name":"verifyingContract",
                       "type":"address"
                    }
                 ],
                 \(safeOperationType)
               },
              "primaryType":"SafeOp",
              "domain":{
                 "chainId": \(domain.chainId),
                 "verifyingContract": "\(domain.verifyingContract)"
              },
              "message":{
                 "safe":"\(userOperation.sender)",
                 "nonce":"\(userOperation.nonce)",
                 "initCode":"\(userOperation.initCode)",
                 "callData":"\(userOperation.callData)",
                 "verificationGasLimit": "\(userOperation.verificationGasLimit)",
                 "callGasLimit": "\(userOperation.callGasLimit)",
                 "preVerificationGas": "\(userOperation.preVerificationGas)",
                 "maxFeePerGas": "\(userOperation.maxFeePerGas)",
                 "maxPriorityFeePerGas": "\(userOperation.maxPriorityFeePerGas)",
                 "paymasterAndData":"\(userOperation.paymasterAndData)",
                 "validAfter":"\(validAfter)",
                 "validUntil":"\(validUntil)",
                 "entryPoint":"\(entryPointAddress.toChecksumAddress())"
              }
           }
       """
        
        return jsonData.data(using: .utf8)!
    }
    
}
