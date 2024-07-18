//
//  SignerUtils.swift
//
//
//  Created by Frederic DE MATOS on 18/07/2024.
//

import Foundation
import web3
import BigInt


public struct SignerUtils {
    public static func passkeySignerSetupCallData(signer: EthereumAccountProtocol, safeConfig: SafeConfig) throws  -> Data {
        
        guard let enableModulesCallData = try EnableModulesFunction(contract: EthereumAddress(safeConfig.safeModuleSetupAddress),
                                                                    modules: [EthereumAddress(safeConfig.ERC4337ModuleAddress)]).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        
        guard let passkeySigner  = signer as? PasskeySigner  else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        let verifiers = EthereumAddress(safeConfig.safeP256VerifierAddress).asNumber()!
        
        
        guard var configureData = try ConfigureFunction(contract: EthereumAddress(safeConfig.safeWebAuthnSharedSignerAddress), x: passkeySigner.passkey.publicX, y: passkeySigner.passkey.publicY, verifiers: verifiers).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        //TODO: DIRTY FIX:
        configureData = configureData.web3.hexString.replacingOccurrences(of: "0xdd8c7d2b", with: "0x0dd9692f").web3.hexData!
        
        let pakedMultiSend = try [MultiSendTransaction(to:  EthereumAddress(safeConfig.safeModuleSetupAddress), data: enableModulesCallData),MultiSendTransaction(to:  EthereumAddress(safeConfig.safeWebAuthnSharedSignerAddress), data: configureData),
       ].pack()
        
        
        guard let multiSendData = try MultiSendFunction(contract: EthereumAddress(safeConfig.safeMultiSendAddress), transactions: pakedMultiSend).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
      
        
        guard let setupCallData = try SetupFunction(contract: EthereumAddress(safeConfig.safeSingletonL2),
                                                    _owners: [signer.address],
                                                    _threshold: BigUInt(1),
                                                    to: EthereumAddress(safeConfig.safeMultiSendAddress),
                                                    calldata: multiSendData,
                                                    fallbackHandler: EthereumAddress(safeConfig.ERC4337ModuleAddress),
                                                    paymentToken: EthereumAddress.zero,
                                                    payment: BigUInt(0),
                                                    paymentReceiver: EthereumAddress.zero
                                                                    ).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
        return setupCallData
    }
    
    
    
    public static func eoaSignerSetupCallData(signer: EthereumAccountProtocol, safeConfig: SafeConfig) throws  -> Data {
        
        guard let enableModulesCallData = try EnableModulesFunction(contract: EthereumAddress(safeConfig.safeModuleSetupAddress),
                                                                    modules: [EthereumAddress(safeConfig.ERC4337ModuleAddress)]).transaction().data else {
            throw SmartAccountError.errorPredictingAddress
        }
        
        
        guard let setupCallData = try SetupFunction(contract: EthereumAddress(safeConfig.safeSingletonL2),
                                                    _owners: [signer.address],
                                                    _threshold: BigUInt(1),
                                                    to: EthereumAddress(safeConfig.safeModuleSetupAddress),
                                                    calldata: enableModulesCallData,
                                                    fallbackHandler: EthereumAddress(safeConfig.ERC4337ModuleAddress),
                                                    paymentToken: EthereumAddress.zero,
                                                    payment: BigUInt(0),
                                                    paymentReceiver: EthereumAddress.zero
                                                                    ).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        return setupCallData
    }
    
    
    
    public static func setupCallData(signer: EthereumAccountProtocol, safeConfig: SafeConfig) throws  -> Data {
        switch signer{
        case is PasskeySigner:
            return try passkeySignerSetupCallData(signer: signer, safeConfig: safeConfig)
        case is EthereumAccount:
            return try eoaSignerSetupCallData(signer: signer, safeConfig: safeConfig)
        default:
            throw SmartAccountError.errorUnsupportedSigner
        }
    }
}
