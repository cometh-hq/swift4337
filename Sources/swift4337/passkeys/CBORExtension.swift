//
//  CBORExtension.swift
//
//
//  Created by Frederic DE MATOS on 18/07/2024.
//
import SwiftCBOR

extension CBOR {
    func toUInt8Array() -> [UInt8]{
        switch self {
        case .byteString(let value):
            return value
        default:
            return []
        }
        
    }
}
