//
//  Passkey.swift
//
//
//  Created by Frederic DE MATOS on 16/07/2024.
//

import BigInt

public struct Passkey {
    let publicKey: String
    let publicX: BigUInt
    let publicY: BigUInt
    
    public init(publicKey: String, publicX: BigUInt, publicY: BigUInt) {
        self.publicKey = publicKey
        self.publicX = publicX
        self.publicY = publicY
    }
}
