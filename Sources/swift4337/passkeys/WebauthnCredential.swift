//
//  CredentialExtension.swift
//
//
//  Created by Frederic DE MATOS on 22/07/2024.
//

import Foundation
import AuthenticationServices
import web3
import BigInt

import os

struct DataView {
    let buffer: Data
    var byteLength: Int { return buffer.count }

    init(data: Data) {
        self.buffer = data
    }

    func getUint8(offset: Int) -> UInt8 {
        return buffer[offset]
    }
}


extension Data {
    
    func calculatePaddedLength() -> Int {
        let length = self.count
        let result = 32 * (Int(ceil(Double(length) / 32.0)) + 1)
        return result
    }
}


public struct WebauthnCredentialData {
    var clientDataJSON: Data
    var signature: Data
    var authenticatorData: Data
    
    init(clientDataJSON: Data, signature: Data, authenticatorData: Data) {
        self.clientDataJSON = clientDataJSON
        self.signature = signature
        self.authenticatorData = authenticatorData
    }
    
    func extractRS() throws-> (BigUInt, BigUInt) {
        
        let view = DataView(data: self.signature)

        func check(_ x: Bool) throws {
            if !x {
                throw NSError(domain: "InvalidSignature", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid signature encoding"])
            }
        }

        func readInt(offset: Int) throws -> (n: BigUInt, end: Int) {
            try check(view.getUint8(offset: offset) == 0x02)
            let len = view.getUint8(offset: offset + 1)
            let start = offset + 2
            let end = start + Int(len)
            let n = BigUInt(hex: view.buffer.subdata(in: start..<end).web3.hexString)!
            return (n, end)
        }

      
        try check(view.getUint8(offset: 0) == 0x30)
        try check(view.getUint8(offset: 1) == view.byteLength - 2)

        let (r, sOffset) = try readInt(offset: 2)
        let (s, _) = try readInt(offset: sOffset)

        return (r, s)
    }
    
    func decodeClientDataFields() throws -> String {
       
        guard let clientDataJSONString = String(data: clientDataJSON, encoding: .utf8) else {
            print("Failed to decode clientDataJSON")
            throw NSError(domain: "InvalidSignature", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid clientDataJSONString"])
        }

        let pattern = #"^\{"type":"webauthn.get","challenge":"[A-Za-z0-9\-_]{43}",(.*)\}$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            print("Invalid regex pattern")
            throw NSError(domain: "InvalidSignature", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid clientDataJSONString"])
        }

        let nsString = clientDataJSONString as NSString
        let results = regex.matches(in: clientDataJSONString, options: [], range: NSRange(location: 0, length: nsString.length))

        guard let match = results.first, match.numberOfRanges > 1 else {
            print("Challenge not found in client data JSON")
            throw NSError(domain: "InvalidSignature", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid clientDataJSONString"])
        }

        let fieldsRange = match.range(at: 1)
        let fields = nsString.substring(with: fieldsRange)

        return fields
    }
    

    func encodeWebAuthnSignature() throws -> Data {
        var r: BigUInt
        var s: BigUInt
        (r, s) = try self.extractRS()
        
        let clientDataFields = try self.decodeClientDataFields()
       
        let signatureBytes = try WebauthnCredentialData.getSignatureBytes(authenticatorData: self.authenticatorData, clientDataFields: clientDataFields, r: r, s: s)
        return signatureBytes
    }
    
    
    
    public static  func getSignatureBytes(authenticatorData: Data, clientDataFields: String, r: BigUInt, s: BigUInt) throws -> Data {
        let authenticatorDataOffset = BigUInt(32 * 4)
        let clientDataFieldsOffset = authenticatorDataOffset + BigUInt(authenticatorData.calculatePaddedLength())
        
        let encodedAuthenticatorDataOffset = try ABIEncoder.encode(authenticatorDataOffset).bytes
        let encodedClientDataFieldsOffset = try ABIEncoder.encode(clientDataFieldsOffset).bytes
        let encodedR = try ABIEncoder.encode(r).bytes
        let encodedS = try ABIEncoder.encode(s).bytes
        let encodedAuthenticatorData = try ABIEncoder.encode(authenticatorData).bytes

        let encodedClientDataFields = try ABIEncoder.encode(clientDataFields).bytes
        
        let signatureData = [ encodedAuthenticatorDataOffset,
                              encodedClientDataFieldsOffset,
                              encodedR,
                              encodedS,
                              encodedAuthenticatorData,
                              encodedClientDataFields
        ].flatMap { $0 }
        
        return Data(signatureData)
    }
    
    
}
