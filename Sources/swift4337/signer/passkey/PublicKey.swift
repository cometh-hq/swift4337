//
//  PublicKey.swift
//
//
//  Created by Frederic DE MATOS on 23/07/2024.
//

public struct PublicKey:Codable {
    var x: String
    var y: String
    
    public init(x: String, y: String) {
        self.x = x
        self.y = y
    }
}
