//
//  UserOperation.swift
//  
//
//  Created by Frederic DE MATOS on 10/06/2024.
//

import Foundation
import web3
import BigInt

public struct UserOperation: Encodable, Decodable {
    
    public var sender: String
    public var nonce: String
    public var factory: String?
    public var factoryData: String?
    public var callData: String
    public var preVerificationGas: String
    public var callGasLimit: String
    public var maxFeePerGas: String
    public var maxPriorityFeePerGas: String
    public var verificationGasLimit: String
    public var paymasterAndData: String
    public var signature: String?
    
    
    public init(sender: String,
                nonce: String,
                factory: String? = nil,
                factoryData: String? = nil,
                callData: String = "0x",
                preVerificationGas: String = "0x00",
                callGasLimit: String = "0x00",
                verificationGasLimit: String = "0x00",
                maxFeePerGas: String = "0x00",
                maxPriorityFeePerGas: String = "0x00",
                paymasterAndData: String = "0x",
                signature: String = "0x000000000000000000000000") {
        self.sender = sender
        self.nonce = nonce
        self.factory = factory
        self.factoryData = factoryData
        self.callData = callData
        self.preVerificationGas = preVerificationGas
        self.callGasLimit = callGasLimit
        self.maxFeePerGas = maxFeePerGas
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.verificationGasLimit = verificationGasLimit
        self.paymasterAndData = paymasterAndData
        self.signature = signature
    }
    
    public func getInitCode() -> String {

        guard self.factory != nil && self.factoryData != nil else {
            return "0x"
        }
        
        let factoryAddress = EthereumAddress(self.factory!)
        let initCode = [factoryAddress.asData()!.bytes, factoryData!.web3.hexData!.bytes].flatMap { $0 }
        return initCode.hexString
    }
}




