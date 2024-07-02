//
//  PaymasterClient.swift
//  
//
//  Created by Frederic DE MATOS on 19/06/2024.
//

import Foundation
import web3



open class PaymasterClient: PaymasterClientProtocol {
    
    public var networkProvider: any web3.NetworkProviderProtocol
    
    public init(url: URL) {
        let networkQueue = OperationQueue()
        networkQueue.name = "4337-sdk.paymaster-client.networkQueue"
        networkQueue.maxConcurrentOperationCount = 4
               
        let session = URLSession(configuration: URLSession.shared.configuration, delegate: nil, delegateQueue: networkQueue)
        self.networkProvider = JSONRPCProvider(session: session, url: url)
    }
}
