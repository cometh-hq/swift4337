

import web3
import BigInt
import Foundation


extension String {
    func removeHexPrefix() -> String {
        return hasPrefix("0x") ? String(dropFirst(2)) : self
    }
    func hexStringToKeccak256Bytes() -> [UInt8] {
        return self.web3.bytesFromHex!.keccak256.web3.bytes
    }
}

extension Data {
    func keccak256Hex() -> String {
        return self.web3.keccak256.web3.hexString
    }
}

public struct DelayModuleUtils {
    
    public static func predictAddress(safeAddress: EthereumAddress, config: RecoveryModuleConfig) throws -> EthereumAddress? {
        let initializer = try getSetUpFunctionData(safeAddress: safeAddress, recoveryModuleConfig: config)
        let moduleAddress = config.delayModuleAddress.removeHexPrefix()
        let safeAddressHex = safeAddress.toChecksumAddress().removeHexPrefix().padLeft(toLength: 64, withPad: "0")
        let initCodeHash = "0x602d8060093d393df3363d3d373d3d3d363d73\(moduleAddress)5af43d82803e903d91602b57fd5bf3".hexStringToKeccak256Bytes()
        let salt = "\(initializer.keccak256Hex())\(safeAddressHex)".hexStringToKeccak256Bytes()
        let predictedAddress = try Create2.getCreate2Address(from: config.moduleFactoryAddress, salt: salt, initCodeHash: initCodeHash)
        return EthereumAddress(predictedAddress)
    }

    public static func getSetUpFunctionData(safeAddress: EthereumAddress, recoveryModuleConfig: RecoveryModuleConfig) throws -> Data {
        let initParams = try getInitParams(safeAddress: safeAddress, recoveryModuleConfig: recoveryModuleConfig)
        let initializer = "0xa4f9edbf000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000a0\(initParams.web3.hexString.removeHexPrefix())"
        return initializer.web3.hexData!
    }

    private static func getInitParams(safeAddress: EthereumAddress, recoveryModuleConfig: RecoveryModuleConfig) throws -> Data {
        let safeAddressData = try ABIEncoder.encode(safeAddress).bytes
        let recoveryCooldownData = try ABIEncoder.encode(BigUInt(recoveryModuleConfig.recoveryCooldown)).bytes
        let recoveryExpirationData = try ABIEncoder.encode(BigUInt(recoveryModuleConfig.recoveryExpiration)).bytes
        let signatureData = [ safeAddressData,
                              safeAddressData,
                              safeAddressData,
                              recoveryCooldownData,
                              recoveryExpirationData
        ].flatMap { $0 }
        return Data(signatureData)
    }

}
