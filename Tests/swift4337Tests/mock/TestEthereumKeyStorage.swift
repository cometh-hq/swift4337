//
//  TestEthereumKeyStorage.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//
import Foundation
import web3

class TestEthereumKeyStorage: EthereumSingleKeyStorageProtocol {
    
    private var privateKey: String

    init(privateKey: String) {
        self.privateKey = privateKey
    }

    func storePrivateKey(key: Data) throws {
    }

    func loadPrivateKey() throws -> Data {
        return privateKey.web3.hexData!
    }
}
