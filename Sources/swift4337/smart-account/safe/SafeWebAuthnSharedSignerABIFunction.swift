//
//  SafeWebAuthnSharedSigner.swift
//  
//
//  Created by Frederic DE MATOS on 16/07/2024.
//

import Foundation
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
    
    // TODO: Web3Swift does not support tuple parameters. Replace function selector with the correct one. Later, implement tuple support for Web3Swift and remove this fix.
    public func data() throws -> Data? {
       let encoder = ABIFunctionEncoder(Self.name)
       try encode(to: encoder)
       let data = try encoder.encoded()

       return data.web3.hexString.replacingOccurrences(of: "0xdd8c7d2b", with: "0x0dd9692f").web3.hexData
   }
}
