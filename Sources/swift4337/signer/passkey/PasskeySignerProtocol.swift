//
//  PasskeySignerProtocol.swift
//
//
//  Created by Frederic DE MATOS on 23/07/2024.
//

import Foundation
import BigInt
import AuthenticationServices
import os
import SwiftCBOR
import web3


public class AuthorizationDelegate:NSObject, ASAuthorizationControllerDelegate {
    
    var signInContinuation: CheckedContinuation<ASAuthorizationPlatformPublicKeyCredentialAssertion, Error>?
    var signUpContinuation: CheckedContinuation<ASAuthorizationPlatformPublicKeyCredentialRegistration, Error>?
  
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
         signInContinuation?.resume(throwing: error)
         signUpContinuation?.resume(throwing: error)
     }
    
}
public protocol PasskeySignerProtocol: SignerProtocol  {
    
    var publicKey: PublicKey  { get set }
    
    var name: String { get }
    var domain: String { get }
    var authorizationDelegate: AuthorizationDelegate {get}
    
    func formatSignature(_ signature: Data) -> String
}

extension PasskeySignerProtocol {
    
    public var publicX: BigUInt {
        
        if let publicX =  BigUInt(hex: self.publicKey.x) {
            return publicX
        }
        
        return BigUInt(0)
    }
    
    public var publicY: BigUInt {
        if let publicY =  BigUInt(hex: self.publicKey.y) {
            return publicY
        }
        return BigUInt(0)
    }
    
    public func publicKeyUserPrefKey() -> String {
        return "passkey-\(self.name)"
    }
    
    public func setPublicKeyUserPref(_ publicKey:PublicKey) throws {
        let jsonData = try JSONEncoder().encode(publicKey)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            Logger.defaultLogger.error(" Error while encoding public key to json string for :\(self.name)")
            throw EthereumAccountError.createAccountError
        }
        UserDefaults.standard.set(jsonString, forKey: self.publicKeyUserPrefKey())
        Logger.defaultLogger.info("Storing passkey: \(self.name) - public key : \(jsonString)")
    }
    
    public func getPublicKeyFromUserPref() throws -> PublicKey?{
        guard let json = UserDefaults.standard.string(forKey: self.publicKeyUserPrefKey()) else {
            Logger.defaultLogger.info("No public key stored for passkey \(self.name)")
            return nil
        }
        
        Logger.defaultLogger.info("User pref for passkey \(self.name) : \(json)")
        
        guard let jsonData = json.data(using: .utf8) else {
            Logger.defaultLogger.info("Invalid public key stored for passkey \(self.name)")
            return nil
        }
        return try JSONDecoder().decode(PublicKey.self, from:jsonData )
    }
    
    public func signMessage(message: web3.TypedData) async throws -> String {
        let hash = try message.signableHash()
        
        let credential =  try await withCheckedThrowingContinuation { continuation in
            self.authorizationDelegate.signInContinuation = continuation
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
     
        return self.formatSignature(encodedWebAuthnSignature)
   }
    
    public func clearStorage() {
        Logger.defaultLogger.info("Clear storage for passkey \(self.name)")
        UserDefaults.standard.removeObject(forKey: self.publicKeyUserPrefKey())
    }

    func signUp(domain: String, name: String, userID: Data) {
         let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
         let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: "0x33".web3.hexData!, name: name, userID: userID)
         let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
            authController.delegate = self.authorizationDelegate
         authController.performRequests()
     }
     
     func signIn(domain: String, challenge: Data) {
         let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
         let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)
         let authController = ASAuthorizationController(authorizationRequests: [ assertionRequest ] )
         authController.delegate = self.authorizationDelegate
       
         if #available(iOS 16.0, *) {
             authController.performRequests(options: .preferImmediatelyAvailableCredentials)
         } else {
             authController.performRequests()
         }
     }

    
    func createPasskey(domain: String, name: String) async throws -> PublicKey {
        
        let credential =  try await withCheckedThrowingContinuation { continuation in
            self.authorizationDelegate.signUpContinuation = continuation
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
            Logger.defaultLogger.error("invalidAuthData")
            throw  EthereumAccountError.createAccountError
        }

        let authenticatorData = try AuthenticatorData(bytes: Data(authDataBytes))
        
        guard let decodedPublicKey = try CBOR.decode(authenticatorData.attestedData!.publicKey) else {
            Logger.defaultLogger.error("decodedPublicKey error")
            throw  EthereumAccountError.createAccountError
        }
        
        guard let x = decodedPublicKey[-2]?.toUInt8Array().hexString else {
            Logger.defaultLogger.error("no x error")
            throw  EthereumAccountError.createAccountError
        }
        guard let y = decodedPublicKey[-3]?.toUInt8Array().hexString else {
            Logger.defaultLogger.error("no x error")
            throw  EthereumAccountError.createAccountError
        }
    
        let publicKey = PublicKey(x: x, y: y)
        try self.setPublicKeyUserPref(publicKey)
        
        return publicKey
    }
    
}
