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
}

public class SafePasskeySigner:NSObject, PasskeySignerProtocol {
 
    var publicX: BigUInt = BigUInt(0)
    var publicY: BigUInt = BigUInt(0)
    
    let domain: String
    
    public let address: EthereumAddress;
   
    public var authorizationDelegate: AuthorizationDelegate = AuthorizationDelegate()
    
    init(publicX: BigUInt, publicY: BigUInt, domain: String, address: EthereumAddress = EthereumAddress(SafeConfig.entryPointV7().safeWebAuthnSharedSignerAddress)) {
        self.publicX = publicX
        self.publicY = publicY
        self.domain = domain
        self.address = address
        super.init()
    }
    
    public init(domain: String, name: String, address: EthereumAddress = EthereumAddress(SafeConfig.entryPointV7().safeWebAuthnSharedSignerAddress)) async throws{
        self.domain = domain
        self.address = address
        
        super.init()
    
        let (xFromPref, yFromPref) = self.getXYFromUserPref()
        
        if let x = xFromPref, let y = yFromPref {
            self.publicX = x
            self.publicY = y
        } else {
            try await self.createPasskey(domain: domain, name: name)
        }
    }
    
    public func setPublicXY(x: BigUInt, y: BigUInt) {
        self.publicX = x
        self.publicY = y
    }
    
    func formatSignature (_ signature: Data) -> String {
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
        
        let signaturePacked =  [validUntilEncoded.bytes, validAfterEncoded.bytes,  signature.web3.hexData!.bytes].flatMap { $0 }
        return signaturePacked.hexString
    }
    

}
