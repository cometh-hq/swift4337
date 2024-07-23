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

public class PasskeySigner:NSObject, SignerProtocol, ASAuthorizationControllerDelegate {
 
    var publicX: BigUInt = BigUInt(0)
    var publicY: BigUInt = BigUInt(0)
    
    let domain: String
    let defaults = UserDefaults.standard
    
    public let address: EthereumAddress =  EthereumAddress(SafeConfig.entryPointV7().safeWebAuthnSharedSignerAddress)
   
    private var signInContinuation: CheckedContinuation<ASAuthorizationPlatformPublicKeyCredentialAssertion, Error>?
    private var signUpContinuation: CheckedContinuation<ASAuthorizationPlatformPublicKeyCredentialRegistration, Error>?
  
    init(publicX: BigUInt, publicY: BigUInt, domain: String) {
       
        self.publicX = publicX
        self.publicY = publicY
        self.domain = domain
        super.init()
    }
    
    public init(domain: String, name: String) async throws{
        self.domain = domain
        super.init()
        
        //TODO: use continuation
        if let x = defaults.string(forKey: "publicX"), let y = defaults.string(forKey: "publicY") {
            //TODO: no force unwrap
            self.publicX = BigUInt(hex:x)!
            self.publicY = BigUInt(hex:y)!
        } else {
            try await self.createPasskey(domain: domain, name: name)
        }
    }
    
    
    public func createPasskey(domain: String, name: String) async throws {
        
        let credential =  try await withCheckedThrowingContinuation { continuation in
            signUpContinuation = continuation
                    self.signUp(domain: domain, name: name, userID: Data(name.utf8))
                }
        
        guard let attestationObject = credential.rawAttestationObject else {
            Logger.defaultLogger.error("invalidAttestationObject")
            throw  EthereumAccountError.createAccountError
        }
  
        let attestationObjectData = attestationObject
        guard let decodedAttestationObject = try? CBOR.decode([UInt8](attestationObjectData)) else {
            Logger.defaultLogger.error("invalidAttestationObject")
            throw  EthereumAccountError.createAccountError
        }

        guard let authData = decodedAttestationObject["authData"],
            case let .byteString(authDataBytes) = authData else {
            Logger.defaultLogger.debug("invalidAuthData")
            throw  EthereumAccountError.createAccountError
        }

        let authenticatorData = try? AuthenticatorData(bytes: Data(authDataBytes))
        
        guard let decodedPublicKey = try! CBOR.decode(authenticatorData!.attestedData!.publicKey) else {
            Logger.defaultLogger.debug("decodedPublicKey error")
            throw  EthereumAccountError.createAccountError
        }
        
        let x = decodedPublicKey[-2]
        let y = decodedPublicKey[-3]
        
        //TODO: Clean
        defaults.set(x!.toUInt8Array().hexString, forKey: "publicX")
        defaults.set(y!.toUInt8Array().hexString, forKey: "publicY")
        self.publicX = BigUInt(hex: x!.toUInt8Array().hexString)!
        self.publicY = BigUInt(hex: y!.toUInt8Array().hexString)!
        
    }
    
    public func signUp(domain: String, name: String, userID: Data) {
         let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
         let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: "0x33".web3.hexData!, name: name, userID: userID)
         let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
         authController.delegate = self
         authController.performRequests()
     }
     
     func signIn(domain: String, challenge: Data) {
       let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
       let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)
       let authController = ASAuthorizationController(authorizationRequests: [ assertionRequest ] )
       authController.delegate = self
       
      
       // If credentials are available, presents a modal sign-in sheet.
       // If there are no locally saved credentials, the system presents a QR code to allow signing in with a
       // passkey from a nearby device.
         //if #available(iOS 16.0, *) {
          //   authController.performRequests(options: .preferImmediatelyAvailableCredentials)
         //} else {
         authController.performRequests()
         //}
     }

    
    public func signMessage(message: web3.TypedData) async throws -> String {
        let hash = try message.signableHash()
        
        let credential =  try await withCheckedThrowingContinuation { continuation in
            signInContinuation = continuation
                    self.signIn(domain: self.domain, challenge: hash)
                }
        
         guard let signature = credential.signature else {
             Logger.defaultLogger.error("Missing signature")
             throw  EthereumAccountError.signError
             
         }
        
         guard let authenticatorData = credential.rawAuthenticatorData else {
             Logger.defaultLogger.error("Missing authenticatorData")
             throw  EthereumAccountError.signError
         }
       
        let webAuthnCredential = WebauthnCredentialData(clientDataJSON: credential.rawClientDataJSON, signature: signature, authenticatorData: authenticatorData)
        let encodedWebAuthnSignature = try webAuthnCredential.encodeWebAuthnSignature()
        
        let safeSignature  =  SafeSignature(signer: self.address.asString(), data: encodedWebAuthnSignature.web3.hexString, dynamic: true)
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
    
    ///
    /// ASAuthorizationControllerDelegate
    ///
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            signUpContinuation?.resume(returning: credential)
            return
            
        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
             signInContinuation?.resume(returning: credential)
            return
             
        default:
            Logger.defaultLogger.error("Unsupported credential action")
            signInContinuation?.resume(throwing: EthereumAccountError.signError)
            return
        }
    }
    
     public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
         Logger.defaultLogger.error("AuthorizationController error: \(error)")
         signInContinuation?.resume(throwing: EthereumAccountError.signError)
     }
}
