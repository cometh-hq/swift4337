
import web3
import XCTest
import BigInt
@testable import swift4337

class DelayModuleABIFunctionsTests: XCTestCase {
    
    func testDeployModuleFunctionIsOk() throws {
        let config = RecoveryModuleConfig.defaultConfig()
        let masterCopy = EthereumAddress(config.delayModuleAddress)
        let initializer = "0xaaaa".web3.hexData!
        let saltNonce = BigUInt("0x4bF81EEF3911db0615297836a8fF351f5Fe08c68".web3.hexData!)
        let delayModuleFactoryCallData = try DeployModuleFunction.callData(masterCopy: masterCopy, initializer: initializer, saltNonce: saltNonce)
        let expected = "0xf1ab873c000000000000000000000000d54895b1121a2ee3f37b502f507631fa1331bed600000000000000000000000000000000000000000000000000000000000000600000000000000000000000004bf81eef3911db0615297836a8ff351f5fe08c680000000000000000000000000000000000000000000000000000000000000002aaaa000000000000000000000000000000000000000000000000000000000000"
        XCTAssertEqual(delayModuleFactoryCallData.web3.hexString, expected)
    }

    func testGetModulesPaginatedFunctionIsOk() throws {
        let callData = try GetModulesPaginatedFunction(
            contract: EthereumAddress("0x9b24CE7A4d940920c479f26d9460F6195C1e86ab"), 
            start: EthereumAddress("0x0000000000000000000000000000000000000000"), 
            pageSize: BigUInt(100)
        ).transaction().data
        XCTAssertEqual(callData?.web3.hexString, "0xcc2f845200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000064")
    }

    func testTxNonceFunctionIsOk() throws {
        let callData = try TxNonceFunction(
            contract: EthereumAddress("0x9b24CE7A4d940920c479f26d9460F6195C1e86ab"), 
            from: EthereumAddress("0x0000000000000000000000000000000000000000")
        ).transaction().data
        XCTAssertEqual(callData?.web3.hexString, "0xc66323e5")
    }

    func testQueueNonceFunctionIsOk() throws {
        let callData = try QueueNonceFunction(
            contract: EthereumAddress("0x9b24CE7A4d940920c479f26d9460F6195C1e86ab"), 
            from: EthereumAddress("0x0000000000000000000000000000000000000000")
        ).transaction().data
        XCTAssertEqual(callData?.web3.hexString, "0xde8dd91d")
    }

    func testSetTxNonceFunctionIsOk() throws {
        let callData = try SetTxNonceFunction.callData(nonce: BigUInt(1))
        XCTAssertEqual(callData.web3.hexString, "0x46ba23070000000000000000000000000000000000000000000000000000000000000001")
    }


        

}
