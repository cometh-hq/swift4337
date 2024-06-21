//
//  BundlerClient.swift
//  
//
//  Created by Frederic DE MATOS on 12/06/2024.
//

import Foundation
import web3
import os

open class BundlerClient: BundlerClientProtocol {
    public var networkProvider: any web3.NetworkProviderProtocol
    
    public init(url: URL) {
        let networkQueue = OperationQueue()
        networkQueue.name = "4337-sdk.bundler-client.networkQueue"
        networkQueue.maxConcurrentOperationCount = 4
               
        let session = URLSession(configuration: URLSession.shared.configuration, delegate: nil, delegateQueue: networkQueue)
        self.networkProvider = HttpNetworkProvider(session: session, url: url)
    }
}
