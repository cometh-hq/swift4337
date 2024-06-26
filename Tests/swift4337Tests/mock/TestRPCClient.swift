//
//  File.swift
//  
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import Foundation
import web3
import swift4337
import os

enum TestRPCClientError: Error {
    case notImplemented
}

class TestRPCClient: EthereumRPCProtocol{
    var networkProvider: any web3.NetworkProviderProtocol
    
    var network: web3.EthereumNetwork
    
    func eth_call(_ transaction: web3.EthereumTransaction, block: web3.EthereumBlock) async throws -> String {
        
        throw TestRPCClientError.notImplemented
    }
    
    func eth_call(_ transaction: web3.EthereumTransaction, resolution: web3.CallResolution, block: web3.EthereumBlock) async throws -> String {
        let safeConfig = SafeConfig.entryPointV7()
        if (transaction.to == EthereumAddress(safeConfig.proxyFactory)) {
          
            //return getProxyCode
            return "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000001e6608060405234801561001057600080fd5b506040516101e63803806101e68339818101604052602081101561003357600080fd5b8101908080519060200190929190505050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614156100ca576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260228152602001806101c46022913960400191505060405180910390fd5b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055505060ab806101196000396000f3fe608060405273ffffffffffffffffffffffffffffffffffffffff600054167fa619486e0000000000000000000000000000000000000000000000000000000060003514156050578060005260206000f35b3660008037600080366000845af43d6000803e60008114156070573d6000fd5b3d6000f3fea264697066735822122003d1488ee65e08fa41e58e888a9865554c535f2c77126a82cb4c0f917f31441364736f6c63430007060033496e76616c69642073696e676c65746f6e20616464726573732070726f76696465640000000000000000000000000000000000000000000000000000"
        } else if (transaction.to == EthereumAddress(safeConfig.entryPointAddress)) {
            //return getNonce
            return "0x0000000000000000000000000000000000000000000000000000000000000005"
            
            //Call GetOwner on test Safe
        } else if (transaction.to == EthereumAddress("0xcfe1e7242dF565f031e1D3F645169Dda9D1230d2")) {
            return "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000009d8A62f656a8d1615C1294fd71e9CFb3E4855A4F"
        }
        throw TestRPCClientError.notImplemented
    }
    
    init(network: web3.EthereumNetwork) {
        self.networkProvider =  TestNetworkProvider()
        self.network = network
    }
}
