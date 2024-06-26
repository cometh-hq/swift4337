<p align="center">
  <img src="https://github.com/cometh-hq/swift4337/blob/0869901c4dafdbafe01aabc13f189d2b89e6a8a1/cometh-logo.png" alt="Cometh"/>
</p>

# Swift4337

Swift4337 is a Swift SDK for building with [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337).

- **Smart Account**: We offer a high-level API for deploying and managing smart accounts (currently supporting Safe Account).

- **Bundler**: Comprehensive support for all bundler methods as defined by [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337#rpc-methods-eth-namespace).

- **Paymaster**: Enables paymaster for gas fee sponsorship.

- **Modular and Extensible**: Easily create and integrate your own smart account, bundlers, paymasters, and signers.

## Installation

### Swift Package Manager

Use Xcode to add to the project (**File -> Swift Packages**) or add this to your `Package.swift` file:

```swift
.package(url: "https://github.com/cometh-hq/swift4337", from: "1.0.0")
```

## Getting Started

### Overview

```swift
import swift4337
import web3
import BigInt

// This is just an example. EthereumKeyLocalStorage should not be used in production code
let keyStorage = EthereumKeyLocalStorage()
let signer = try EthereumAccount.create(replacing: keyStorage, keystorePassword: "MY_PASSWORD")

guard let rpcUrl = URL(string: "https://an-infura-or-similar-url.com/123") else { return }
let rpc = EthereumHttpClient(url: rpcUrl)

guard let bundlerUrl = URL(string: "https://cometh-or-similar-4337-provider/123") else { return }
let bundler = BundlerClient(url: bundlerUrl))

let smartAccount = try await SafeAccount(signer: signer, rpc: rpc, bundler: bundler)

let userOpHash = try smartAccount.sendUserOperation(to: DEST_ADDRESSS, value: BigUInt(1))
```

### Smart Account

Allows users to interact with their smart accounts, encapsulating ERC-4337 logic such as deploying the smart account on the first operation, estimating user operations, and sponsoring gas.

#### Safe Account

In this first version of Swift4337, we provide support for [Safe Accounts](https://safe.global/).

```swift
let smartAccount = try await SafeAccount(signer: signer, rpc: rpc, bundler: bundler, paymaster: paymaster)

let userOpHash = try smartAccount.sendUserOperation(to: DEST_ADDRESSS, value: BigUInt(1))

```

Init Method

```swift
init(address: EthereumAddress? = nil,
     signer: EthereumAccount,
     rpc: EthereumRPCProtocol,
     bundler: BundlerClientProtocol,
     paymaster: PaymasterClientProtocol? = nil,
     safeConfig: SafeConfig = SafeConfig())
```

- address: If nil, the address of the Safe account will be predicted based on the signer address.
- paymaster: If specified, it will be used when preparing the user operation to sponsor gas fees.
- safeConfig: If not provided, the default configuration will be used.

```swift
// these values are from the safe deployments repo
public struct SafeConfig {
    public var safeSingletonL2 = "0x29fcB43b46531BcA003ddC8FCB67FFE91900C762"
    public var proxyFactory = "0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67"
    public var ERC4337ModuleAddress = "0xa581c4A4DB7175302464fF3C06380BC3270b4037"
    public var safeModuleSetupAddress = "0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47"
    public var entryPointAddress = "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"
    public var creationNonce = BigUInt(0)
}
```

#### Smart Account Prococol

Any smart account implementation have to respect this protocol.

```swift
public protocol SmartAccountProtocol {

    var address: EthereumAddress {get}
    var signer: EthereumAccount {get}

    var rpc: EthereumRPCProtocol {get}
    var bundler: BundlerClientProtocol {get}
    var paymaster: PaymasterClientProtocol? {get}

    var chainId: Int {get}
    var entryPointAddress: EthereumAddress {get}

    // Methods already implemented by SmartAccountProtocol (see extension below)
    func prepareUserOperation(to: EthereumAddress, value: BigUInt, data: Data) async throws -> UserOperation
    func sendUserOperation(to: EthereumAddress, value: BigUInt, data: Data) async throws -> String
    func isDeployed() async throws -> Bool
    func getNonce(key: BigUInt) async throws -> BigUInt

    // Methods to be implemented for each type of smart account
    func getInitCode() async throws -> Data
    func getCallData(to: EthereumAddress, value:BigUInt, data:Data) throws -> Data
    func getOwners() async throws -> [EthereumAddress]
    func signUserOperation(_ userOperation: UserOperation) throws -> Data
}
```

Methods implemented directly by the SmartAccountProtocol:

- **prepareUserOperation**: Prepares the user operation, get the initCode if the account is not deployed, calls the paymaster if available, and obtains the gas estimation.
- **sendUserOperation**: Prepares the user operation, signs it, sends it to the bundler, and returns a user operation hash.
- **getNonce**: Returns the current nonce for the smart wallet from the entry point.
- **isDeployed**: Returns true if the smart account is already deployed.

To be compatible with Swift4337, a smart account must provide the following methods (currently, we support Safe Accounts and provide [the implementation](https://github.com/cometh-hq/swift4337/blob/main/Sources/swift4337/smart-account/safe/SafeAccount.swift)):

- **getInitCode**: Returns the InitCode required to deploy the wallet on the first user operation.
- **signUserOperation**: Signs the user operation with the signer associated with the smart account.
- **getCallData**: Returns the callData to execute the transactions parameters (to, value, data and operation).
- **getOwners**: Returns the list of owners of the smart account.

### Signer

To control a Smart Account, users need a Signer for authentication.

Create an instance of EthereumAccount with an EthereumKeyStorage provider.

**NOTE: We recommend implementing your own KeyStorage provider instead of relying on the provided EthereumKeyLocalStorage class. The provided class is only an example conforming to the EthereumSingleKeyStorageProtocol. For more details check [web3.swift repository](https://github.com/argentlabs/web3.swift)**.

```swift
import web3

// This is just an example. EthereumKeyLocalStorage should not be used in production code
let keyStorage = EthereumKeyLocalStorage()
let account = try? EthereumAccount.create(replacing: keyStorage, keystorePassword: "MY_PASSWORD")
```

### RPC

To interact with the blockchain and call methods on smart contracts, you need an RPC.

```swift
guard let clientUrl = URL(string: "https://an-infura-or-similar-url.com/123") else { return }
let client = EthereumHttpClient(url: clientUrl)
```

All available methods are available [here](https://github.com/argentlabs/web3.swift/blob/develop/web3swift/src/Client/Protocols/EthereumClientProtocol.swift).

Swift4337 provide [an extension](https://github.com/cometh-hq/swift4337/blob/main/Sources/swift4337/gas-estimator/EthereumRPCProtocol%2Beth_feeHistory.swift) to use eth_feeHistory.

### Bundler

To send, estimate, and get user operations receipts, you need a Bundler.

```swift
guard let bundlerUrl = URL(string: "https://cometh-or-similar-4337-provider/123") else { return }
let bundler = BundlerClient(url: bundlerUrl))
```

Available methods:

- **eth_sendUserOperation**: This method submits a User Operation (UserOp) to the mempool. If the operation is accepted, it returns a userOpHash.

- **eth_estimateUserOperationGas** : Estimates the gas values required for a given User Operation, including PreVerificationGas, VerificationGas, and CallGasLimit.

- **eth_getUserOperationByHash**: Retrieves a User Operation and its transaction context based on a given userOpHash.

- **eth_getUserOperationReceipt**: Fetches the receipt of a User Operation based on a given userOpHash. The receipt includes metadata and the final status of the UserOp.

- **eth_supportedEntryPoints**: Returns an array of supported EntryPoint addresses.

### Paymaster

To sponsorise gas for users you need a Paymaster client.

```swift
guard let paymasterUrl = URL(string: "https://cometh-or-similar-4337-provider/123") else { return }
let paymaster = PaymasterClient(url: paymasterrUrl)
```

Available methods:

- **pm_sponsorUserOperation**: Submit a UserOperation to the paymaster. If approved for sponsorship, it returns the paymasterAndData along with updated gas values

- **pm_supportedEntryPoints**: eturns an array of supported EntryPoint addresses.

## Dependencies

Swift4337 is built on top of [web3.swift](https://github.com/argentlabs/web3.swift).

Web3.swift offers excellent features for interacting with web3, which we leverage for the following components:

- **EthereumAccount**: A wrapper around EOA (Externally Owned Accounts) for use in Swift4337.
- **EthereumHttpClient (RPC)**: Provides access to RPC functions for interacting with blockchain nodes.
- **ABI Encoding/Decoding**: Facilitates data encoding and decoding for interacting with smart contracts.

We encourage you to read the web3.swift [web3.swift documentation](https://github.com/argentlabs/web3.swift/blob/develop/README.md) for more details on how to use these components.

## Contributors

The initial project was crafted by the team at Cometh. However, we encourage anyone to help implement new features and to keep this library up-to-date. Please follow the [contributing guidelines](https://github.com/cometh-hq/swift4337/blob/main/CONTRIBUTING.md).

## License

Released under the [Apache License](https://github.com/cometh-hq/swift4337/blob/main/LICENSE.txt).
