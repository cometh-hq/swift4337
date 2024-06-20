//
//  BundlerClient.swift
//
//
//  Created by Frederic DE MATOS on 12/06/2024.
//

import Foundation
import BigInt
import web3

extension ABIEncoder {
    public static func encode(_ value: BigUInt, uintSize: Int) throws -> ABIEncoder.EncodedValue  {
        var encoded = [UInt8]()
        let bytesSize = uintSize / 8
        
        let bytes = value.web3.bytes // should be <= 32 bytes
        guard bytes.count <= 32, bytesSize <= 32 else {
            throw ABIError.invalidValue
        }
    
        let size = (bytesSize - bytes.count)
        guard size >=  0  else {
            throw ABIError.invalidValue
        }
        
        encoded = [UInt8](repeating: 0x00, count:size) + bytes
        
         return .value(
            bytes: encoded,
            isDynamic: false,
            staticLength:  32
        )
    }
}
