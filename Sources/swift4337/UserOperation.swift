//
//  UserOperation.swift
//  
//
//  Created by Frederic DE MATOS on 10/06/2024.
//

import Foundation
import web3
import BigInt

public enum UserOperationError: Error, Equatable {
    case errorGeneratingPaymasterAndData
}

public struct UserOperation: Encodable, Decodable {
    
    public var sender: String
    public var nonce: String
    public var factory: String?
    public var factoryData: String?
    public var callData: String
    
    public var preVerificationGas: String
    public var callGasLimit: String
    public var verificationGasLimit: String
    
    public var maxFeePerGas: String
    public var maxPriorityFeePerGas: String
    
    public var paymaster: String?
    public var paymasterData: String?
    public var paymasterVerificationGasLimit: String?
    public var paymasterPostOpGasLimit: String?

    public var signature: String
    
    
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
                paymaster: String? = nil,
                paymasterData: String? = nil,
                paymasterVerificationGasLimit: String? = nil,
                paymasterPostOpGasLimit: String? = nil,
                signature: String) {
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
        self.signature = signature
        
        self.paymaster = paymaster
        self.paymasterData = paymasterData
        self.paymasterVerificationGasLimit = paymasterVerificationGasLimit
        self.paymasterPostOpGasLimit = paymasterPostOpGasLimit
    }
    
    public func getInitCode() -> String {

        guard self.factory != nil && self.factoryData != nil else {
            return "0x"
        }
        
        let factoryAddress = EthereumAddress(self.factory!)
      let initCode = [factoryAddress.asData()!.web3.bytes, factoryData!.web3.hexData!.web3.bytes].flatMap { $0 }
        return initCode.hexString
    }
    
    public func getPaymasterAndData() throws -> String {
        guard self.paymaster != nil &&
                self.paymasterData != nil &&
                self.paymasterVerificationGasLimit != nil &&
                self.paymasterPostOpGasLimit != nil
                
        else {
            return "0x"
        }
        
        let verificationGasLimit = BigUInt(hex: self.paymasterVerificationGasLimit!)
        let postOpGasLimit = BigUInt(hex: self.paymasterPostOpGasLimit!)
        
        guard verificationGasLimit != nil && postOpGasLimit != nil else {
            throw UserOperationError.errorGeneratingPaymasterAndData
        }
        
        let verificationGasLimitEncoded =  try ABIEncoder.encode(verificationGasLimit!, uintSize: 128)
        let postOpGasLimitEncoded =  try ABIEncoder.encode(BigUInt(postOpGasLimit!), uintSize: 128)
        
      let paymasterAndData = [EthereumAddress(self.paymaster!).asData()!.web3.bytes,
                                verificationGasLimitEncoded.bytes,
                                postOpGasLimitEncoded.bytes,
                              self.paymasterData!.web3.hexData!.web3.bytes
                                
        ].flatMap { $0 }
        
        return paymasterAndData.hexString
    }
}




