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
    
    
    static let EIP712_SAFE_OPERATION_TYPE = """
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
    
    static func eip712Data(domain: EIP712Domain, userOperation: UserOperation, validUntil: BigUInt, validAfter: BigUInt, entryPointAddress: EthereumAddress)-> Data {
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
                 \(EIP712_SAFE_OPERATION_TYPE)
               },
              "primaryType":"SafeOp",
              "domain":{
                 "chainId": \(domain.chainId),
                 "verifyingContract": "\(domain.verifyingContract)"
              },
              "message":{
                 "safe":"\(userOperation.sender)",
                 "nonce":"\(userOperation.nonce)",
                 "initCode":"\(userOperation.getInitCode())",
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
