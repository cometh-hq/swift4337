//
//  GasEstimatorProtocol.swift
//  
//
//  Created by Frederic DE MATOS on 02/07/2024.
//

import Foundation
import BigInt

public enum GasEstimatorError: Error, Equatable {
    case invalidLatestBaseFeePerGas
    case cannotCalculateMaxBaseFee
}

public struct GasFee {
    public let maxFeePerGas: BigUInt
    public let maxPriorityFeePerGas: BigUInt
}


public protocol GasEstimatorProtocol {
    var baseFeePercentMultiplier: Int {get}
    var priorityFeePercentMultiplier: Int {get}
    var minBaseFee:BigUInt {get}
    var minPriorityFee: BigUInt {get}
    
    func getGasFees() async throws -> GasFee
}
