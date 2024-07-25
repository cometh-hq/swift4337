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
    public var safeWebAuthnSharedSignerAddress: String
    public var safeMultiSendAddress: String
    public var safeP256VerifierAddress: String
    public var creationNonce = BigUInt(0)
    
    init(safeSingletonL2: String,
                proxyFactory: String,
                ERC4337ModuleAddress: String,
                safeModuleSetupAddress: String,
                entryPointAddress: String,
                safeWebAuthnSharedSignerAddress: String,
                safeMultiSendAddress: String,
                safeP256VerifierAddress: String,
                creationNonce: BigUInt = BigUInt(0)) {
        self.safeSingletonL2 = safeSingletonL2
        self.proxyFactory = proxyFactory
        self.ERC4337ModuleAddress = ERC4337ModuleAddress
        self.safeModuleSetupAddress = safeModuleSetupAddress
        self.creationNonce = creationNonce
        self.entryPointAddress = entryPointAddress
        self.safeWebAuthnSharedSignerAddress = safeWebAuthnSharedSignerAddress
        self.safeMultiSendAddress = safeMultiSendAddress
        self.safeP256VerifierAddress = safeP256VerifierAddress
    }
    
    public static func entryPointV7() ->SafeConfig{
        return SafeConfig(safeSingletonL2: "0x29fcB43b46531BcA003ddC8FCB67FFE91900C762",
                          proxyFactory: "0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67",
                          ERC4337ModuleAddress: "0x75cf11467937ce3F2f357CE24ffc3DBF8fD5c226",
                          safeModuleSetupAddress: "0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47",
                          entryPointAddress: "0x0000000071727De22E5E9d8BAf0edAc6f37da032",
                          safeWebAuthnSharedSignerAddress: "0xfD90FAd33ee8b58f32c00aceEad1358e4AFC23f9",
                          safeMultiSendAddress: "0x38869bf66a61cF6bDB996A6aE40D5853Fd43B526",
                          safeP256VerifierAddress: "0x445a0683e494ea0c5AF3E83c5159fBE47Cf9e765")
    }
}

