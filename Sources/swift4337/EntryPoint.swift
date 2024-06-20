//
//  EntryPointFunctions.swift
//
//
//  Created by Frederic DE MATOS on 11/06/2024.
//

import Foundation
import web3
import BigInt


public struct GetNonceResponse: ABIResponse, MulticallDecodableResponse {
       public static var types: [ABIType.Type] = [BigUInt.self]
       public let value: BigUInt

       public init?(values: [ABIDecoder.DecodedValue]) throws {
           self.value = try values[0].decoded()
       }
   }

//function getNonce(address sender, uint192 key)
public struct GetNonceFunction: ABIFunction {
   
    public static let name = "getNonce"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?

    public let sender: EthereumAddress
    public let key: BigUInt

    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        
        sender: EthereumAddress,
        key: BigUInt
    ) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.sender = sender
        self.key = key
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(sender)
        try encoder.encode(key, staticSize: 192)
    }
}

struct EntryPoint {
    public let address: EthereumAddress
    private let client: EthereumRPCProtocol
  
    public init(client: EthereumRPCProtocol, address:EthereumAddress) {
        self.client = client
        self.address = address
    }
    
    public func getNonce(sender: EthereumAddress, key: BigUInt) async throws -> BigUInt {
        let function = GetNonceFunction(contract: self.address, sender: sender, key: key)
        let data = try await function.call(withClient: client, responseType: GetNonceResponse.self)
        return data.value
    } 
}
