//
//  SafeABI.swift
//  Test4337Wallet
//
//  Created by Frederic DE MATOS on 14/06/2024.
//

import Foundation
import web3
import BigInt

struct ExecuteUserOpFunction: ABIFunction {
       public static let name = "executeUserOp"
       public let gasPrice: BigUInt?
       public let gasLimit: BigUInt?
       public var contract: EthereumAddress
       public let from: EthereumAddress?

       public let to: EthereumAddress
       public let value: BigUInt
       public let calldata: Data
       public let operation: UInt8

       public init(
           contract: EthereumAddress,
           from: EthereumAddress? = nil,
           gasPrice: BigUInt? = nil,
           gasLimit: BigUInt? = nil,
           to: EthereumAddress,
           value: BigUInt,
           calldata: Data,
           operation: UInt8
       ) {
           self.contract = contract
           self.from = from
           self.gasPrice = gasPrice
           self.gasLimit = gasLimit
           self.to = to
           self.value = value
           self.calldata = calldata
           self.operation = operation
       }

       public func encode(to encoder: ABIFunctionEncoder) throws {
           try encoder.encode(to)
           try encoder.encode(value)
           try encoder.encode(calldata)
           try encoder.encode(operation)
       }
   }

 //function setup(address[] calldata _owners, uint256 _threshold, address to, bytes calldata data, address fallbackHandler, address paymentToken, uint256 payment, address payable paymentReceiver)
struct SetupFunction: ABIFunction {
    public static let name = "setup"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?

    public let _owners: [EthereumAddress]
    public let _threshold: BigUInt
    public let to: EthereumAddress
    public let calldata: Data
    public let fallbackHandler: EthereumAddress
    public let paymentToken: EthereumAddress
    public let payment: BigUInt
    public let paymentReceiver: EthereumAddress
    
    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        
        _owners: [EthereumAddress],
        _threshold: BigUInt,
        to: EthereumAddress,
        calldata: Data,
        fallbackHandler: EthereumAddress,
        paymentToken: EthereumAddress,
        payment: BigUInt,
        paymentReceiver: EthereumAddress
    ) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        
        self._owners = _owners
        self._threshold = _threshold
        self.to = to
        self.calldata = calldata
        self.fallbackHandler = fallbackHandler
        self.paymentToken = paymentToken
        self.payment = payment
        self.paymentReceiver = paymentReceiver
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(_owners)
        try encoder.encode(_threshold)
        try encoder.encode(to)
        try encoder.encode(calldata)
        try encoder.encode(fallbackHandler)
        try encoder.encode(paymentToken)
        try encoder.encode(payment)
        try encoder.encode(paymentReceiver)
    }
}


//function getOwners() public view override returns (address[] memory) {
struct GetOwnersFunction: ABIFunction {
       public static let name = "getOwners"
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


public struct GetOwnersResponse: ABIResponse, MulticallDecodableResponse {
       public static var types: [ABIType.Type] = [ABIArray<EthereumAddress>.self]
       public let value: [EthereumAddress]

       public init?(values: [ABIDecoder.DecodedValue]) throws {
           self.value = try values[0].decodedArray()
       }
   }


//function getOwners() public view override returns (address[] memory) {
struct AddOwnerWithThresholdFunction: ABIFunction {
        public static let name = "addOwnerWithThreshold"
        public let gasPrice: BigUInt?
        public let gasLimit: BigUInt?
        public var contract: EthereumAddress
        public let from: EthereumAddress?
    
        public let owner: EthereumAddress
        public let _threshold: BigUInt
    

        public init(
            contract: EthereumAddress,
            from: EthereumAddress? = nil,
            gasPrice: BigUInt? = nil,
            gasLimit: BigUInt? = nil,
            owner: EthereumAddress,
            _threshold: BigUInt
        ) {
            self.contract = contract
            self.from = from
            self.gasPrice = gasPrice
            self.gasLimit = gasLimit
            
            self.owner = owner
            self._threshold = _threshold

        }

        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(owner)
            try encoder.encode(_threshold)
        }
   }

// function isValidSignature(bytes _message, bytes calldata _signature)
struct IsValidSignatureFunction: ABIFunction {
    public static let name = "isValidSignature"
    public var contract: EthereumAddress
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let from: EthereumAddress? = nil
    
    public let message: Data
    public let signature: Data
    
    
    public init(
        contract: EthereumAddress,
        message: Data,
        signature: Data
    ) {
        self.contract = contract
        self.message = message
        self.signature = signature
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(message)
        try encoder.encode(signature)
    }
}

public struct IsValidSignatureResponse: ABIResponse {
    static let MAGICVALUE = Data(hex: "0x20c13b0b")
    public static var types: [ABIType.Type] = [Data4.self]
    
    public let isValid: Bool
    
    public init?(values: [ABIDecoder.DecodedValue]) throws {
        let decoded = try values[0].decoded() as Data
        self.isValid = decoded == Self.MAGICVALUE
    }
    
}

public struct EnableModuleFunction {
    public static func callData(
        moduleAddress: EthereumAddress
    ) throws -> Data {
        let encoder = ABIFunctionEncoder("enableModule")
        try encoder.encode(moduleAddress)
        return try encoder.encoded()
    }
}





