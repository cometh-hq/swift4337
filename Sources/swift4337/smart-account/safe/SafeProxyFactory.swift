//
//  SafeProxyFactory.swift
//  Test4337Wallet
//
//  Created by Frederic DE MATOS on 14/06/2024.
//

import Foundation
import web3
import BigInt
import os



public struct ProxyCreationCodeResponse: ABIResponse, MulticallDecodableResponse {
       public static var types: [ABIType.Type] = [Data.self]
       public let value: Data

       public init?(values: [ABIDecoder.DecodedValue]) throws {
           self.value = try values[0].decoded()
       }
   }

// function proxyCreationCode() public pure returns (bytes memory)
public struct ProxyCreationCodeFunction: ABIFunction {
   
    public static let name = "proxyCreationCode"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?


    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil
    ) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {

    }
}


//function createProxyWithNonce(address _singleton, bytes memory initializer, uint256 saltNonce) public returns (SafeProxy proxy) {
public struct CreateProxyWithNonceFunction: ABIFunction {
    
    public static let name = "createProxyWithNonce"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?
    
    public let _singleton: EthereumAddress
    public let initializer: Data
    public let saltNonce: BigUInt
    
    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
    
        _singleton: EthereumAddress,
        initializer: Data,
        saltNonce: BigUInt
    ) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        
        self._singleton = _singleton
        self.initializer = initializer
        self.saltNonce = saltNonce
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(_singleton)
        try encoder.encode(initializer)
        try encoder.encode(saltNonce)
    }
    
}

struct SafeProxyFactory {
    public let address: EthereumAddress
    private let client: EthereumRPCProtocol
  
    public init(client: EthereumRPCProtocol, address:String) {
        self.client = client
        self.address = EthereumAddress(address)
    }
    
    public func proxyCreationCode() async throws -> Data {
        let function = ProxyCreationCodeFunction(contract: self.address)
        let data = try await function.call(withClient: client, responseType: ProxyCreationCodeResponse.self)
        return data.value
    }
}
