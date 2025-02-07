import Foundation

public struct RecoveryModuleConfig {
    public var moduleFactoryAddress: String
    public var delayModuleAddress: String
    public var recoveryCooldown: Int
    public var recoveryExpiration: Int

    public init(
        moduleFactoryAddress: String,
        delayModuleAddress: String,
        recoveryCooldown: Int,
        recoveryExpiration: Int
    ) {
        self.moduleFactoryAddress = moduleFactoryAddress
        self.delayModuleAddress = delayModuleAddress
        self.recoveryCooldown = recoveryCooldown
        self.recoveryExpiration = recoveryExpiration
    }
    
    public static func defaultConfig() -> RecoveryModuleConfig {
        return RecoveryModuleConfig(moduleFactoryAddress: "0x000000000000aDdB49795b0f9bA5BC298cDda236",
                                    delayModuleAddress: "0xd54895B1121A2eE3f37b502F507631FA1331BED6",
                                    recoveryCooldown: 86400,
                                    recoveryExpiration: 604800
        )
    }
}
