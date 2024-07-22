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
 
    
    let defaults = UserDefaults.standard
    
    var publicX: BigUInt = BigUInt(0)
    var publicY: BigUInt = BigUInt(0)
    
    let domain: String
    
    private var credentialContinuation: CheckedContinuation<ASAuthorizationPlatformPublicKeyCredentialAssertion, Error>?
       
    init(publicX: BigUInt, publicY: BigUInt, domain: String) {
       
        self.publicX = publicX
        self.publicY = publicY
        self.domain = domain
        super.init()
    }
    
    public init(domain: String, name: String) {
        self.domain = domain
        super.init()
        
        //TODO: use continuation
        if let x = defaults.string(forKey: "publicX"), let y = defaults.string(forKey: "publicY") {
            //TODO: no force unwrap
            self.publicX = BigUInt(hex:x)!
            self.publicY = BigUInt(hex:y)!
        } else {
            self.signUp(domain: domain, name: name, userID: Data(name.utf8))
        }
    }

    public let address: EthereumAddress =  EthereumAddress(SafeConfig.entryPointV7().safeWebAuthnSharedSignerAddress)
    
    
    public func signMessage(message: web3.TypedData) async throws -> String {
        let hash = try message.signableHash()
        
        let credential =  try await withCheckedThrowingContinuation { continuation in
            credentialContinuation = continuation
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
    
    
    ///
    ///
    ///
    ///
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Logger.defaultLogger.debug("ICI")
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            Logger.defaultLogger.debug("A new passkey was registered: \(credential)")
          
            guard let attestationObject = credential.rawAttestationObject else { return }
      
            let clientDataJSON = credential.rawClientDataJSON
            let credentialID = credential.credentialID
            Logger.defaultLogger.debug("credentialID: \(credentialID.web3.hexString)")
             
            let attestationObjectData = attestationObject
            guard let decodedAttestationObject = try? CBOR.decode([UInt8](attestationObjectData)) else {
                Logger.defaultLogger.debug("invalidAttestationObject")
                return
            }

            guard let authData = decodedAttestationObject["authData"],
                case let .byteString(authDataBytes) = authData else {
                Logger.defaultLogger.debug("invalidAuthData")
                return
            }
            guard let formatCBOR = decodedAttestationObject["fmt"],
                case let .utf8String(format) = formatCBOR,
                let attestationFormat = AttestationFormat(rawValue: format) else {
                Logger.defaultLogger.debug("invalidFmt")
                return
            }

            guard let attestationStatement = decodedAttestationObject["attStmt"] else {
                Logger.defaultLogger.debug("missingAttStmt")
                return
                
            }
            
        let authenticatorData = try? AuthenticatorData(bytes: Data(authDataBytes))
            Logger.defaultLogger.debug("authenticatorData : \(authenticatorData!.attestedData!.publicKey.hexString), \(authenticatorData!.attestedData!.credentialID.hexString))")
            
            guard let decodedPublicKey = try! CBOR.decode(authenticatorData!.attestedData!.publicKey) else {
                Logger.defaultLogger.debug("decodedPublicKey error")
                return
            }
            
             
            let x = decodedPublicKey[-2]
            print("x \(x!.toUInt8Array().hexString)")
            let y = decodedPublicKey[-3]
            print("y \(y!.toUInt8Array().hexString)")
            
            //TODO: Clean
            defaults.set(x!.toUInt8Array().hexString, forKey: "publicX")
            defaults.set(y!.toUInt8Array().hexString, forKey: "publicY")
            self.publicX = BigUInt(hex: x!.toUInt8Array().hexString)!
            self.publicY = BigUInt(hex: y!.toUInt8Array().hexString)!
            
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
           // Take steps to verify the challenge.
            Logger.defaultLogger.debug("verify")
            Logger.defaultLogger.debug("A passkey was used to sign in: \(credential)")
            credentialContinuation?.resume(returning: credential)

            
         } else {
           // Handle other authentication cases, such as Sign in with Apple.
             credentialContinuation?.resume(throwing: EthereumAccountError.signError)
             Logger.defaultLogger.debug("other")
       }
    }
    
    
   public func signUp(domain: String, name: String, userID: Data) {
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
        let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: "0x33".web3.hexData!, name: name, userID: userID)
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController.delegate = self
        //authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    func signIn(domain: String, challenge: Data) {
      let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
      let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)
      
      // Pass in any mix of supported sign-in request types.
      let authController = ASAuthorizationController(authorizationRequests: [ assertionRequest ] )
      authController.delegate = self
     // authController.presentationContextProvider = self
      
     
      // If credentials are available, presents a modal sign-in sheet.
      // If there are no locally saved credentials, the system presents a QR code to allow signing in with a
      // passkey from a nearby device.
        //if #available(iOS 16.0, *) {
         //   authController.performRequests(options: .preferImmediatelyAvailableCredentials)
        //} else {
            authController.performRequests()
        //}
    }

     public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
         credentialContinuation?.resume(throwing: EthereumAccountError.signError)
         Logger.defaultLogger.debug("la \(error)")
     }
}
