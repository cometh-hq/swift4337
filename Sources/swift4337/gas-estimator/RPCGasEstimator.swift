//
//  RPCGasEstimator.swift
//
//
//  Created by Frederic DE MATOS on 13/06/2024.
//

import Foundation
import web3
import BigInt



open class RPCGasEstimator: GasEstimatorProtocol {
    private let rpc: EthereumRPCProtocol
    public let baseFeePercentMultiplier: Int
    public let priorityFeePercentMultiplier: Int
    public let minBaseFee:BigUInt
    public let minPriorityFee: BigUInt
    
    public init(_ rpc: EthereumRPCProtocol, baseFeePercentMultiplier: Int = 200, priorityFeePercentMultiplier: Int = 120, minBaseFee:BigUInt = BigUInt(0), minPriorityFee: BigUInt = BigUInt(0)) {
        self.rpc = rpc
        
        self.baseFeePercentMultiplier = baseFeePercentMultiplier
        self.priorityFeePercentMultiplier = priorityFeePercentMultiplier
        self.minBaseFee = minBaseFee
        self.minPriorityFee = minPriorityFee
    }
    
    public func getGasFees() async throws -> GasFee {
        let feeHistory = try await self.rpc.eth_feeHistory()
        
        guard let latestBaseFeePerGas = feeHistory.baseFeePerGas.last else {
            throw GasEstimatorError.invalidLatestBaseFeePerGas
        }
        
        guard var adjustedMaxBaseFee = BigUInt(hex: latestBaseFeePerGas)?.multiplied(by: BigUInt(baseFeePercentMultiplier)).quotientAndRemainder(dividingBy: BigUInt(100)).quotient else {
            throw GasEstimatorError.cannotCalculateMaxBaseFee
        }
        
        let priorityFeesPerBlock = feeHistory.reward.map({ BigUInt(hex: $0[0]) ?? BigUInt(0) })
        
        var priorityFeeMedian = BigUInt(0)
        if (priorityFeesPerBlock.count != 0) {
            priorityFeeMedian = priorityFeesPerBlock.reduce(BigUInt(0), { x, y in x + y}).quotientAndRemainder(dividingBy: BigUInt(priorityFeesPerBlock.count)).quotient
        }
        
        var adjustedMaxPriorityFee = priorityFeeMedian.multiplied(by: BigUInt(priorityFeePercentMultiplier)).quotientAndRemainder(dividingBy: BigUInt(100)).quotient
      
        
        if adjustedMaxPriorityFee < minPriorityFee {
            adjustedMaxPriorityFee = minPriorityFee
        }
        
        adjustedMaxBaseFee = adjustedMaxBaseFee + adjustedMaxPriorityFee
       
    
        if adjustedMaxBaseFee < minBaseFee {
            adjustedMaxBaseFee = minBaseFee
        }
        
        return GasFee(maxFeePerGas: adjustedMaxBaseFee, maxPriorityFeePerGas: adjustedMaxPriorityFee)
    }
    
}

