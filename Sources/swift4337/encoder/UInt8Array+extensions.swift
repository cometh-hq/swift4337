//
//  UInt8Array+extensions.swift
//
//
//  Created by Frederic DE MATOS on 17/06/2024.
//

import Foundation
import keccaktiny


public extension [UInt8]{
    var keccak256: Data {
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        defer {
            result.deallocate()
        }
        let nsData = Data(self) as NSData
        let input = nsData.bytes.bindMemory(to: UInt8.self, capacity: Data(self).count)
        keccak_256(result, 32, input, Data(self).count)
        return Data(bytes: result, count: 32)
    }
    
    func slice(_ offset: Int) -> [UInt8]  {
        return [UInt8](self[offset...])
    }
    
    var hexString: String {
        return String(hexFromBytes: self)
    }
}
