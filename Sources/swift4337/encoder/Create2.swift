//
//  Create2.swift
//
//
//  Created by Frederic DE MATOS on 17/06/2024.
//

import Foundation
import web3
import os


public struct Create2  {

    static public func getCreate2Address(from: String, salt: [UInt8], initCodeHash: [UInt8]) throws -> String {
        let fromEncoded = try ABIEncoder.encode(EthereumAddress(from), packed: true)
        let concatened = ["0xff".web3.hexData!.bytes, fromEncoded.bytes, salt, initCodeHash].flatMap { $0 }
        let ethAddress = EthereumAddress(concatened.keccak256.bytes.slice(12).hexString)
        return ethAddress.toChecksumAddress()
    }
    
    
}

