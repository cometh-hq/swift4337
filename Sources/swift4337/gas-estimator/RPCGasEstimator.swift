//
//  RPCGasEstimator.swift
//
//
//  Created by Frederic DE MATOS on 13/06/2024.
//

import Foundation
import web3
import BigInt

public enum GasEstimatorError: Error, Equatable {
    case invalidLatestBaseFeePerGas
    case cannotCalculateMaxBaseFee
}

public struct GasFee {
    public let maxFeePerGas: BigUInt
    public let maxPriorityFeePerGas: BigUInt
}

open class RPCGasEstimator {
    private let rpc: EthereumRPCProtocol
    
    public init(_ rpc: EthereumRPCProtocol) {
        self.rpc = rpc
    }
    
    public func getGasFees(baseFeePercentMultiplier: Int = 200, priorityFeePercentMultiplier: Int = 120 ) async throws -> GasFee {
        let feeHistory = try await self.rpc.eth_feeHistory()
        
        guard let latestBaseFeePerGas = feeHistory.baseFeePerGas.last else {
            throw GasEstimatorError.invalidLatestBaseFeePerGas
        }
        
        guard let adjustedMaxBaseFee = BigUInt(hex: latestBaseFeePerGas)?.multiplied(by: BigUInt(baseFeePercentMultiplier)).quotientAndRemainder(dividingBy: BigUInt(100)).quotient else {
            throw GasEstimatorError.cannotCalculateMaxBaseFee
        }
        
        let priorityFeesPerBlock = feeHistory.reward.map({ BigUInt(hex: $0[0]) ?? BigUInt(0) })
        
        var priorityFeeMedian = BigUInt(0)
        if (priorityFeesPerBlock.count != 0) {
            priorityFeeMedian = priorityFeesPerBlock.reduce(BigUInt(0), { x, y in x + y}).quotientAndRemainder(dividingBy: BigUInt(priorityFeesPerBlock.count)).quotient
        }
        
        let adjustedMaxPriorityFee = priorityFeeMedian.multiplied(by: BigUInt(priorityFeePercentMultiplier)).quotientAndRemainder(dividingBy: BigUInt(100)).quotient
        return GasFee(maxFeePerGas: adjustedMaxBaseFee + adjustedMaxPriorityFee, maxPriorityFeePerGas: adjustedMaxPriorityFee)
    }
    
}

