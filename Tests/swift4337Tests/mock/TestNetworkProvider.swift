//
//  TestNetworkProvider.swift
//
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import Foundation
import web3


class TestNetworkProvider: NetworkProviderProtocol {
    var session: URLSession
    
    func send<P, U>(method: String, params: P, receive: U.Type) async throws -> Any where P : Encodable, U : Decodable {
        throw TestRPCClientError.notImplemented
    }
    
    init() {
        let networkQueue = OperationQueue()
        networkQueue.name = "test.client.networkQueue"
        networkQueue.maxConcurrentOperationCount = 4
        let session = URLSession(configuration:URLSession.shared.configuration, delegate: nil, delegateQueue: networkQueue)
        
        self.session = session
    }
    
}
