//
//  File.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import web3
import swift4337

enum TestBundlerClientError: Error {
    case notImplemented

}

struct TestBundlerClient: BundlerClientProtocol{
    var networkProvider: any web3.NetworkProviderProtocol
    init() {
        self.networkProvider =  TestNetworkProvider()
    }
}
