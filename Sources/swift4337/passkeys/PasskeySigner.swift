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

public class PasskeySigner:NSObject, EthereumAccountProtocol, ASAuthorizationControllerDelegate {
    let defaults = UserDefaults.standard
    
    var publicX: BigUInt = BigUInt(0)
    var publicY: BigUInt = BigUInt(0)
    
    let domain: String
   
    init(publicX: BigUInt, publicY: BigUInt, domain: String) {
       
        self.publicX = publicX
        self.publicY = publicY
        self.domain = domain
        super.init()
    }
    
    public init(domain: String, name: String) {
        self.domain = domain
        super.init()
        if let x = defaults.string(forKey: "publicX"), let y = defaults.string(forKey: "publicY") {
            //TODO: no force unwrap
            self.publicX = BigUInt(hex:x)!
            self.publicY = BigUInt(hex:y)!
        } else {
            self.signUp(domain: domain, name: name, userID: Data(name.utf8))
        }
    }

    public let address: EthereumAddress =  EthereumAddress(SafeConfig.entryPointV7().safeWebAuthnSharedSignerAddress)

    
    public func sign(data: Data) throws -> Data {
        throw PasskeySignerError.errorNotImplemented
    }

    public func sign(hex: String) throws -> Data {
        throw PasskeySignerError.errorNotImplemented
    }

    public func sign(hash: String) throws -> Data {
        throw PasskeySignerError.errorNotImplemented
    }

    public func sign(message: Data) throws -> Data {
        throw PasskeySignerError.errorNotImplemented
    }

    public func sign(message: String) throws -> Data {
        throw PasskeySignerError.errorNotImplemented
    }

    public func signMessage(message: Data) throws -> String {
        throw PasskeySignerError.errorNotImplemented
    }
    
    public func signMessage(message: web3.TypedData) throws -> String {
      
       let hash = try message.signableHash()
        self.signIn(domain: self.domain, challenge: hash)

      
       return ""
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
           
            guard let signature = credential.signature else {
                print("Missing signature")
                return
            }
            Logger.defaultLogger.debug("signature \(signature.web3.hexString)")
            
            guard let authenticatorData = credential.rawAuthenticatorData else {
                print("Missing authenticatorData")
                return
            }
            
            Logger.defaultLogger.debug("authenticatorData \(authenticatorData.web3.hexString)")
            
            guard let userID = credential.userID else {
                print("Missing userID")
                return
            }
            Logger.defaultLogger.debug("userID \(userID.web3.hexString)")
            
            let clientDataJSON = credential.rawClientDataJSON
            let credentialId = credential.credentialID
            
            
         } else {
           // Handle other authentication cases, such as Sign in with Apple.
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
         Logger.defaultLogger.debug("la \(error)")
     }
}
