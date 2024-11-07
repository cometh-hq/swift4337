import Foundation
import BigInt
import web3


public struct TransactionParams {
    let to: EthereumAddress
    let value: BigUInt
    let data: Data
    let delegateCall: Bool
    
    public init(to: EthereumAddress, value: BigUInt, data: Data, delegateCall: Bool = false) {
        self.to = to
        self.value = value
        self.data = data
        self.delegateCall = delegateCall
    }
}
