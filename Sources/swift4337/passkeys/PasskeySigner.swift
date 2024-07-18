//
//  PasskeySigner.swift
//
//
//  Created by Frederic DE MATOS on 16/07/2024.
//

import Foundation
import web3
import os


public enum PasskeySignerError: Error, Equatable {
    case errorNotImplemented
}

public class PasskeySigner: EthereumAccountProtocol {
 
    public let passkey: Passkey
   
    public let address: EthereumAddress

    init(passkey: Passkey, address: EthereumAddress) {
        self.passkey = passkey
        self.address = address
    }
    
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
        throw PasskeySignerError.errorNotImplemented
    }
}
