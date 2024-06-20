//
//  File.swift
//  Test4337Wallet
//
//  Created by Frederic DE MATOS on 14/06/2024.
//

import Foundation
import BigInt


public struct SafeConfig {
    public var safeSingletonL2: String
    public var proxyFactory: String
    public var ERC4337ModuleAddress: String
    public var safeModuleSetupAddress: String
    public var entryPointAddress:String
    public var creationNonce = BigUInt(0)
    
    public init(safeSingletonL2: String = "0x29fcB43b46531BcA003ddC8FCB67FFE91900C762", 
                proxyFactory: String = "0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67", 
                ERC4337ModuleAddress: String = "0xa581c4A4DB7175302464fF3C06380BC3270b4037",
                safeModuleSetupAddress: String = "0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47",
                entryPointAddress:String = "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789",
                creationNonce: BigUInt = BigUInt(0)) {
        self.safeSingletonL2 = safeSingletonL2
        self.proxyFactory = proxyFactory
        self.ERC4337ModuleAddress = ERC4337ModuleAddress
        self.safeModuleSetupAddress = safeModuleSetupAddress
        self.creationNonce = creationNonce
        self.entryPointAddress = entryPointAddress
    }
}

