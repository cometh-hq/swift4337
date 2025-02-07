import web3
import XCTest
import BigInt
@testable import swift4337

class DelayModuleUtilsTests: XCTestCase {
    
    func testPredictDelayModuleAddressIsOk() async throws {
        let safeAddress = EthereumAddress("0x4bF81EEF3911db0615297836a8fF351f5Fe08c68")
        let recoveryModuleConfig = RecoveryModuleConfig.defaultConfig()
        let predictedAddress = try DelayModuleUtils.predictAddress(safeAddress: safeAddress, config: recoveryModuleConfig)
        XCTAssertEqual(predictedAddress?.toChecksumAddress(), "0x9b24CE7A4d940920c479f26d9460F6195C1e86ab")
    }

}
