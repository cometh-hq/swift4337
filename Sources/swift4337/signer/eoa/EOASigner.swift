//
//  EOASigner.swift
//
//
//  Created by Frederic DE MATOS on 18/07/2024.
//

import Foundation
import web3

public extension EthereumAccount {
    func toSigner()-> EOASigner {
        return EOASigner(ethereumAccount: self)
    }
}

public class EOASigner: SignerProtocol {
    
  
    let ethereumAccount: EthereumAccount
    
    public var address: EthereumAddress {
        return self.ethereumAccount.address
    }
    
    init(ethereumAccount: EthereumAccount) {
        self.ethereumAccount = ethereumAccount
    }
    
    public func signMessage(message: web3.TypedData) async throws -> String {
        return try self.ethereumAccount.signMessage(message: message)
    }
    
    public func dummySignature() throws -> String { return "0xecececececececececececececececececececececececececececececececec"}

    
}
