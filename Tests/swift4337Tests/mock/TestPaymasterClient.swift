//
//  File.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//


import web3
import swift4337

enum TestPaymasterClientError: Error {
    case notImplemented

}

struct TestPaymasterClient: PaymasterClientProtocol{
    var networkProvider: any web3.NetworkProviderProtocol
    init() {
        self.networkProvider =  TestNetworkProvider()
    }    
}
