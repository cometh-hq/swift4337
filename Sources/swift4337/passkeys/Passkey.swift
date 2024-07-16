//
//  Passkey.swift
//
//
//  Created by Frederic DE MATOS on 16/07/2024.
//


public struct Passkey {
    let publicKey: String
    let publicX: String
    let publicY: String
    
    public init(publicKey: String, publicX: String, publicY: String) {
        self.publicKey = publicKey
        self.publicX = publicX
        self.publicY = publicY
    }
}
