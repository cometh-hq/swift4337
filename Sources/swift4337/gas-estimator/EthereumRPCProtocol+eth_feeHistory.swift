//
//  EthereumHttpClient+eth_feeHistory.swift
//
//

//  Created by Frederic DE MATOS on 13/06/2024.
//

import Foundation
import web3
import BigInt

public struct FeeHistoryResponse: Decodable {
    public let oldestBlock: String
    public let reward : [[String]]
    public let baseFeePerGas: [String]
    public let gasUsedRatio: [Double]
}


extension EthereumRPCProtocol {
 
    public func eth_feeHistory() async throws -> FeeHistoryResponse {
         
        let params = [AnyEncodable("5"), AnyEncodable("latest"), AnyEncodable([40])]
        
         do {
             let data = try await networkProvider.send(method: "eth_feeHistory", params: params, receive: FeeHistoryResponse.self)
             
             if let feeHistory = data as? FeeHistoryResponse {
                 return feeHistory
             } else {
                 throw EthereumClientError.unexpectedReturnValue
             }
         } catch {
             if case let .executionError(result) = error as? JSONRPCError {
                 throw EthereumClientError.executionError(result.error)
             } else if case .executionError = error as? EthereumClientError, let error = error as? EthereumClientError {
                 throw error
             } else {
                 throw EthereumClientError.unexpectedReturnValue
             }
         }
     }
}
