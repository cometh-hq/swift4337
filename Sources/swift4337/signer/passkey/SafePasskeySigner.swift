//
//  PasskeySigner.swift
//
//
//  Created by Frederic DE MATOS on 16/07/2024.
//

import Foundation
import web3
import os
import SwiftCBOR
import AuthenticationServices
import BigInt


public enum PasskeySignerError: Error, Equatable {
    case errorNotImplemented
    case errorGetSignerAddress
    case errorMissingRPCCLient
}

public class SafePasskeySigner:NSObject, PasskeySignerProtocol {
 
    public var publicKey: PublicKey
    
    public let domain: String
    public let name: String
    public var address: EthereumAddress;
    
   
    public var authorizationDelegate: AuthorizationDelegate = AuthorizationDelegate()
    
    init(publicKey: PublicKey, name: String,  domain: String, address: EthereumAddress = EthereumAddress(SafeConfig.entryPointV7().safeWebAuthnSharedSignerAddress)) {
        self.publicKey = publicKey
        self.domain = domain
        self.address = address
        self.name = name
        super.init()
    }
    
    public init(domain: String, name: String,  isSharedWebauthnSigner:Bool = true, safeConfig: SafeConfig = SafeConfig.entryPointV7(), rpc: EthereumRPCProtocol? = nil) async throws{
        self.domain = domain
        self.name = name
        self.address = EthereumAddress.zero
        
        self.publicKey = PublicKey(x: "", y: "")
        super.init()
       
        if let publicKey = try self.getPublicKeyFromUserPref()  {
            self.publicKey = publicKey
        } else {
            self.publicKey = try await self.createPasskey(domain: domain, name: name)
        }
        
        if (isSharedWebauthnSigner == true) {
            self.address = EthereumAddress(safeConfig.safeWebAuthnSharedSignerAddress)
        } else {
            let verifiers = EthereumAddress(safeConfig.safeP256VerifierAddress).asNumber()!
          
            guard let rpcClient = rpc else {
                Logger.defaultLogger.error("Error no RPC Provided ")
                throw PasskeySignerError.errorMissingRPCCLient
            }
            
            let functionGetSigner =  GetSignerFunction(contract:  EthereumAddress(safeConfig.safeWebauthnSignerFactory), x: self.publicX, y: self.publicY, verifiers: verifiers)
          
            
            self.address = try await functionGetSigner.call(withClient:rpcClient , responseType: GetSignerResponse.self).value
            
        }
    }
    
    public func formatSignature (_ signature: Data) -> String {
        let safeSignature  =  SafeSignature(signer: self.address.asString(), data: signature.web3.hexString, dynamic: true)
        return SignerUtils.buildSignatureBytes(signatures: [safeSignature])
    }
    
    public func dummySignature() throws ->  String {
        let dummyAuthenticatorData = "0xfefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe04fefefefe".web3.hexData!
        let dummyClientData_fields = "\"origin\":\"http://safe.global\",\"padding\":\"This pads the clientDataJSON so that we can leave room for additional implementation specific fields for a more accurate 'preVerificationGas' estimate.\""
        
        let dummyR = BigUInt(hex: "0xecececececececececececececececececececececececececececececececec")!;
        let dummyS = BigUInt(hex: "0xd5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5ad5af")!;
        
        let signatureBytes = try WebauthnCredentialData.getSignatureBytes(authenticatorData: dummyAuthenticatorData,
                                                                          clientDataFields: dummyClientData_fields,
                                                                          r: dummyR,
                                                                          s: dummyS)
                            
        let safeSignature = SafeSignature(signer: self.address.asString(), data: signatureBytes.web3.hexString, dynamic: true)
        let signature = SignerUtils.buildSignatureBytes(signatures: [safeSignature])
        
        let validUntilEncoded =  try ABIEncoder.encode(BigUInt(0), uintSize: 48)
        let validAfterEncoded =  try ABIEncoder.encode(BigUInt(0), uintSize: 48)
        
      let signaturePacked =  [validUntilEncoded.bytes, validAfterEncoded.bytes,  signature.web3.hexData!.web3.bytes].flatMap { $0 }
        return signaturePacked.hexString
    }
    

}
