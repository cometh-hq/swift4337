//
//  SignerProtocol.swift
//  
//
//  Created by Frederic DE MATOS on 18/07/2024.
//

import Foundation
import web3

public protocol SignerProtocol {
    var address: EthereumAddress { get }
    
    func signMessage(message: TypedData) async throws -> String
    func dummySignature() throws -> String
}
