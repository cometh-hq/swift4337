import web3
import Foundation
import BigInt

struct DeployModuleFunction {

    public static func callData(
        masterCopy: EthereumAddress,
        initializer: Data,
        saltNonce: BigUInt
    ) throws -> Data {
        let encoder = ABIFunctionEncoder("deployModule")
        try encoder.encode(masterCopy)
        try encoder.encode(initializer)
        try encoder.encode(saltNonce)
        return try encoder.encoded()
    }
    
}

// getModulesPaginated(address start, uint256 pageSize) external view override returns (address[] memory array, address next)
struct GetModulesPaginatedFunction: ABIFunction {
    public static let name = "getModulesPaginated"
    public let gasPrice: BigUInt?
    public let gasLimit: BigUInt?
    public var contract: EthereumAddress
    public let from: EthereumAddress?
    //params
    public let start: EthereumAddress
    public let pageSize: BigUInt

    public init(
        contract: EthereumAddress,
        from: EthereumAddress? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil,
        start: EthereumAddress,
        pageSize: BigUInt
    ) {
        self.contract = contract
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.start = start
        self.pageSize = pageSize
    }

    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(start)
        try encoder.encode(pageSize)
    }

}


public struct GetModulesPaginatedResponse: ABIResponse {
    public static var types: [ABIType.Type] = [ABIArray<EthereumAddress>.self, EthereumAddress.self]
    public let array: [EthereumAddress]
    public let next: EthereumAddress

    public init?(values: [ABIDecoder.DecodedValue]) throws {
        self.array = try values[0].decodedArray()
        self.next = try values[1].decoded()
    }
}


// txNonce() returns (uint256)
struct TxNonceFunction: ABIFunction {
    public static let name = "txNonce"
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


public struct TxNonceResponse: ABIResponse {
    public static var types: [ABIType.Type] = [BigUInt.self]
    public let value: BigUInt

    public init?(values: [ABIDecoder.DecodedValue]) throws {
        self.value = try values[0].decoded()
    }
}

// queueNonce() returns (uint256)
struct QueueNonceFunction: ABIFunction {
    public static let name = "queueNonce"
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

public struct QueueNonceResponse: ABIResponse {
    public static var types: [ABIType.Type] = [BigUInt.self]
    public let value: BigUInt

    public init?(values: [ABIDecoder.DecodedValue]) throws {
        self.value = try values[0].decoded()
    }
}

struct SetTxNonceFunction  {
    public static func callData(
        nonce: BigUInt
    ) throws -> Data {
        let encoder = ABIFunctionEncoder("setTxNonce")
        try encoder.encode(nonce)
        return try encoder.encoded()
    }
}
