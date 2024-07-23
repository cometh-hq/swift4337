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
         signInContinuation?.resume(throwing: EthereumAccountError.signError)
     }
    
}
protocol PasskeySignerProtocol: SignerProtocol  {
    var publicX: BigUInt { get set }
    var publicY: BigUInt { get set }
    
    var domain: String { get }
    var authorizationDelegate: AuthorizationDelegate {get}
    
    func setPublicXY(x: BigUInt, y: BigUInt)
    func formatSignature(_ signature: Data) -> String
}

extension PasskeySignerProtocol {
    
    public func publicXKey() -> String{
        return "publicX"
    }
    
    public func publicYKey() -> String{
        return "publicY"
    }
    
    public func setXYUserPref(x: String, y: String) {
        UserDefaults.standard.set(x, forKey: self.publicXKey())
        UserDefaults.standard.set(y, forKey: self.publicYKey())
    }
    
    public func getXYFromUserPref() -> (x: BigUInt?, y: BigUInt?){
        var x: BigUInt?
        var y: BigUInt?
        
        if let xHex = UserDefaults.standard.string(forKey: self.publicXKey()) {
            x = BigUInt(hex: xHex)
        }
        
        if let yHex = UserDefaults.standard.string(forKey: self.publicYKey()) {
            y = BigUInt(hex: yHex)
        }
        
        return (x,y)
    }

    public func signUp(domain: String, name: String, userID: Data) {
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
    
    
    public func createPasskey(domain: String, name: String) async throws {
        
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
    
        guard let xBigUInt =  BigUInt(hex: x) else {
            Logger.defaultLogger.error("invalid x error")
            throw  EthereumAccountError.createAccountError
        }
        
        guard let yBigUInt =  BigUInt(hex: y) else {
            Logger.defaultLogger.error("invalid y error")
            throw  EthereumAccountError.createAccountError
        }
        self.setPublicXY(x: xBigUInt, y: yBigUInt)
        self.setXYUserPref(x:x, y:y)
    }
    
}
