//
//  SafeWebAuthnSignerFactoryABIFunction.swift
//
//
//  Created by Frederic DE MATOS on 29/07/2024.
//

import Foundation
import web3
import BigInt
import os


struct GetSignerFunction: ABIFunction {
    
    public static let name = "getSigner"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?
    
    public let x: BigUInt
    public let y: BigUInt
    public let verifiers : BigUInt
    
    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        x:BigUInt,
        y:BigUInt,
        verifiers:BigUInt
    ) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        
        self.x = x;
        self.y = y
        self.verifiers = verifiers
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(x)
        try encoder.encode(y)
        try encoder.encode(verifiers, staticSize: 176)
    }
}

public struct GetSignerResponse: ABIResponse, MulticallDecodableResponse {
    public static var types: [ABIType.Type] = [EthereumAddress.self]
    public let value: EthereumAddress
    
    public init?(values: [ABIDecoder.DecodedValue]) throws {
        self.value = try values[0].decoded()
    }
}

struct CreateSignerFunction: ABIFunction {
    
    public static let name = "createSigner"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?
    
    public let x: BigUInt
    public let y: BigUInt
    public let verifiers : BigUInt
    
    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        x:BigUInt,
        y:BigUInt,
        verifiers:BigUInt
    ) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        
        self.x = x;
        self.y = y
        self.verifiers = verifiers
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(x)
        try encoder.encode(y)
        try encoder.encode(verifiers, staticSize: 176)
    }
}
