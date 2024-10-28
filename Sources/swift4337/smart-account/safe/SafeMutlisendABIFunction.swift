//
//  SafeMutlisendABIFunction.swift
//  
//
//  Created by Frederic DE MATOS on 16/07/2024.
//

import Foundation
import web3
import BigInt

public struct MultiSendTransaction  {
 
    let op: BigUInt
    let to: EthereumAddress
    let value: BigUInt
    let data: Data
    
    init(op: BigUInt = BigUInt(1), to: EthereumAddress, value: BigUInt = BigUInt(0), data: Data) {
        self.op = op
        self.to = to
        self.value = value
        self.data = data
    }

    public func pack() throws-> Data {
        let opEncoded =  try ABIEncoder.encode(self.op, uintSize: 8)
        let valueEncoded =  try ABIEncoder.encode(self.value)
      let dataSizeEncoded = try ABIEncoder.encode(BigUInt(self.data.web3.bytes.count))
        
      return Data([opEncoded.bytes, self.to.asData()!.web3.bytes, valueEncoded.bytes,  dataSizeEncoded.bytes, self.data.web3.bytes].flatMap { $0 })
        
    }
}

extension [MultiSendTransaction] {
    
    public func pack() throws -> Data {
        let packedTx = try self.flatMap { try $0.pack() }
        return Data(packedTx)
    }
}


struct MultiSendFunction: ABIFunction {
    
    public static let name = "multiSend"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?
    
    public let transactions : Data

    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        transactions: Data) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        
        self.transactions = transactions;
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(transactions)
    }
}
