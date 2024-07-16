//
//  SafeWebAuthnSharedSigner.swift
//  
//
//  Created by Frederic DE MATOS on 16/07/2024.
//

import web3
import BigInt


struct ConfigureFunction: ABIFunction {
    
    public static let name = "configure"
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
        try encoder.encode(verifiers)
    }
}
