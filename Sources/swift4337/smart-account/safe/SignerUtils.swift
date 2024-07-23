//
//  SignerUtils.swift
//
//
//  Created by Frederic DE MATOS on 18/07/2024.
//

import Foundation
import web3
import BigInt

struct SafeSignature {
    var signer: String
    var data: String
    var dynamic: Bool
}

extension String {
    func padLeft(toLength: Int, withPad: String = " ") -> String {
        let newLength = self.count
        if newLength < toLength {
            return String(repeating: withPad, count: toLength - newLength) + self
        } else {
            return self
        }
    }
}

public struct SignerUtils {
    
    static func buildSignatureBytes(signatures: [SafeSignature]) -> String {
        let SIGNATURE_LENGTH_BYTES = 65

        let sortedSignatures = signatures.sorted {
            $0.signer.lowercased() < $1.signer.lowercased()
        }

        var signatureBytes = "0x"
        var dynamicBytes = ""

        for sig in sortedSignatures {
            if sig.dynamic {
                /*
                    A contract signature has a static part of 65 bytes and the dynamic part that needs to be appended
                    at the end of signature bytes.
                    The signature format is
                    Signature type == 0
                    Constant part: 65 bytes
                    {32-bytes signature verifier}{32-bytes dynamic data position}{1-byte signature type}
                    Dynamic part (solidity bytes): 32 bytes + signature data length
                    {32-bytes signature length}{bytes signature data}
                */
                let dynamicPartPosition = String((sortedSignatures.count * SIGNATURE_LENGTH_BYTES + dynamicBytes.count / 2), radix: 16).padLeft(toLength: 64, withPad: "0")
                let dynamicPartLength = String(sig.data.dropFirst(2).count / 2, radix: 16).padLeft(toLength: 64, withPad: "0")
                let staticSignature = "\(String(sig.signer.dropFirst(2)).padLeft(toLength: 64, withPad: "0"))\(dynamicPartPosition)00"
                let dynamicPartWithLength = "\(dynamicPartLength)\(sig.data.dropFirst(2))"

                signatureBytes += staticSignature
                dynamicBytes += dynamicPartWithLength
            } else {
                signatureBytes += sig.data.dropFirst(2)
            }
        }

        return signatureBytes + dynamicBytes
    }
    
     static func passkeySignerSetupCallData(signer: SignerProtocol, safeConfig: SafeConfig) throws  -> Data {
        
        guard let enableModulesCallData = try EnableModulesFunction(contract: EthereumAddress(safeConfig.safeModuleSetupAddress),
                                                                    modules: [EthereumAddress(safeConfig.ERC4337ModuleAddress)]).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        
        guard let passkeySigner  = signer as? SafePasskeySigner  else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        let verifiers = EthereumAddress(safeConfig.safeP256VerifierAddress).asNumber()!
        
        
        guard var configureData = try ConfigureFunction(contract: EthereumAddress(safeConfig.safeWebAuthnSharedSignerAddress), x: passkeySigner.publicX, y: passkeySigner.publicY, verifiers: verifiers).transaction().data else {
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
    
    
    
    static func eoaSignerSetupCallData(signer: SignerProtocol, safeConfig: SafeConfig) throws  -> Data {
        
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
    
    
    
    public static func setupCallData(signer: SignerProtocol, safeConfig: SafeConfig) throws  -> Data {
        switch signer{
        case is SafePasskeySigner:
            return try passkeySignerSetupCallData(signer: signer, safeConfig: safeConfig)
        case is EOASigner:
            return try eoaSignerSetupCallData(signer: signer, safeConfig: safeConfig)
        default:
            throw SmartAccountError.errorUnsupportedSigner
        }
    }
}
