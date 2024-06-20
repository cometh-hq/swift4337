//
//  SafeModuleSetupABIFunction.swift
//  Test4337Wallet
//
//  Created by Frederic DE MATOS on 14/06/2024.
//

import Foundation
import web3
import BigInt



struct EnableModulesFunction: ABIFunction {
    
    public static let name = "enableModules"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?
    
    public let modules : [EthereumAddress]


    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        modules:[EthereumAddress]
    ) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        
        self.modules = modules
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(modules)
    }
}
