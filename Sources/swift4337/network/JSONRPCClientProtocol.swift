//
//  JSONRPCClientProtocol.swift
//
//
//  Created by Frederic DE MATOS on 19/06/2024.
//

import Foundation
import web3

public struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        encodeClosure = { encoder in
            try value.encode(to: encoder)
        }
    }

    public func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}

struct JSONRPCRequest<T: Encodable>: Encodable {
    public let jsonrpc: String
    public let method: String
    public let params: T
    public let id: Int
}

public protocol JSONRPCClientProtocol {
    var networkProvider: NetworkProviderProtocol { get }
}

extension JSONRPCClientProtocol{
    func failureHandler(_ error: Error) -> EthereumClientError {
        if case let .executionError(result) = error as? JSONRPCError {
            return EthereumClientError.executionError(result.error)
        } else if case .executionError = error as? EthereumClientError, let error = error as? EthereumClientError {
            return error
        } else {
            return EthereumClientError.unexpectedReturnValue
        }
    }
}
