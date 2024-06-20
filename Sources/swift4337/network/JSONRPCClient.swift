//
//  BaseNetworkClient.swift
//
//
//  Created by Frederic DE MATOS on 19/06/2024.
//

import Foundation
import web3

struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        encodeClosure = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}

struct JSONRPCRequest<T: Encodable>: Encodable {
    public let jsonrpc: String
    public let method: String
    public let params: T
    public let id: Int
}

open class JSONRPCClient {
    public let url: URL
    
    let networkProvider: HttpNetworkProvider
    
    private let session: URLSession
    
    public init(url: URL) {
        self.url = url
        
        let networkQueue = OperationQueue()
        networkQueue.name = "4337-sdk.client.networkQueue"
        networkQueue.maxConcurrentOperationCount = 4
               
        self.session = URLSession(configuration: URLSession.shared.configuration, delegate: nil, delegateQueue: networkQueue)
        self.networkProvider = HttpNetworkProvider(session: session, url: url)
    }
    
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
