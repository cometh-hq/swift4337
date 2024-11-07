import Foundation
import BigInt
import web3


public struct TransactionParams {
    let to: EthereumAddress
    let value: BigUInt
    let data: Data
    let delegateCall: Bool = false
}
