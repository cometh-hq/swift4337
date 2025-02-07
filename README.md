<p align="center">
  <img src="https://github.com/cometh-hq/swift4337/blob/0869901c4dafdbafe01aabc13f189d2b89e6a8a1/cometh-logo.png" alt="Cometh"/>
</p>

# Swift4337

Swift4337 is a Swift SDK for building with [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337).

- **Smart Account**: We offer a high-level API for deploying and managing smart accounts (currently supporting Safe Account).

- **Bundler**: Comprehensive support for all bundler methods as defined by [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337#rpc-methods-eth-namespace).

- **Paymaster**: Enables paymaster for gas fee sponsorship.

- **Signers**: Supports both traditional EOA signers and Passkey signers, enabling flexible and secure authentication mechanisms.

- **Modular and Extensible**: Easily create and integrate your own smart account, bundlers, paymasters, and signers.

## Installation

### Swift Package Manager

Use Xcode to add to the project (**File -> Swift Packages**) or add this to your `Package.swift` file:

```swift
.package(url: "https://github.com/cometh-hq/swift4337", from: "0.2.0")
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
     safeConfig: SafeConfig = SafeConfig.entryPointV7(),
     gasEstimator: GasEstimatorProtocol? = nil)
```

- address: If nil, the address of the Safe account will be predicted based on the signer address.
- paymaster: If specified, it will be used when preparing the user operation to sponsor gas fees.
- safeConfig: If not provided, the default configuration will be used.
- gasEstimator: By default will use an RPCGasEstimator.

```swift
// these values are from the safe deployments repo
(https://github.com/safe-global/safe-modules-deployments/tree/main/src/assets/safe-4337-module)
public static func entryPointV7() ->SafeConfig{
    return SafeConfig(safeSingletonL2: "0x29fcB43b46531BcA003ddC8FCB67FFE91900C762",
                      proxyFactory: "0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67",
                      ERC4337ModuleAddress: "0x75cf11467937ce3F2f357CE24ffc3DBF8fD5c226",
                      safeModuleSetupAddress: "0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47",
                      entryPointAddress: "0x0000000071727De22E5E9d8BAf0edAc6f37da032")
}
```

#### Smart Account Prococol

Any smart account implementation have to respect this protocol.

```swift
public protocol SmartAccountProtocol {

    var address: EthereumAddress {get}
    var signer: EthereumAccount {get}
    var gasEstimator: GasEstimatorProtocol {get}

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
    func getFactoryAddress() -> EthereumAddress
    func getFactoryData() async throws -> Data
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

- **getFactoryAddress**: Returns the address of the factory to be used to deploy the wallet.
- **getFactoryData**: Returns the call data to be passed to the factory to deploy the wallet.
- **signUserOperation**: Signs the user operation with the signer associated with the smart account.
- **getCallData**: Returns the callData to execute the transactions parameters (to, value, data and operation).
- **getOwners**: Returns the list of owners of the smart account.

### Signer

To control a Smart Account, users need a Signer for authentication.

#### Passkey Signer

Passkeys provide enhanced security and simplify authentication through quick methods like biometrics.
Supported by Apple, Google, and Microsoft, they are widely implemented on iOS and Android.
Their adoption improves the user experience by making authentication faster and simpler.

On chain contracts use ERC-1271 and WebAuthn standards for verifying WebAuthn signatures with the secp256r1 curve.

At the instantiation of the Signer, if the passkey was not already created for this name, the process of the registration is started and user will have to use his biometrics.

Then when a request to sign a message is received, the user has to use its biometric to sign the message.

> [!IMPORTANT]  
> You need to have an associated domain with the webcredentials service type to use Passkey Signer otherwise it will return an error.
> See Apple documentation on [Supporting associated domains](https://developer.apple.com/documentation/Xcode/supporting-associated-domains) for more information.

> [!IMPORTANT]  
> When initializing a Safe Account with a Passkey signer it will use the Safe WebAuthn Shared Signer to respect 4337 limitation. For more information have a look at [Safe Documentation](https://github.com/safe-global/safe-modules/tree/main/modules/passkey/contracts/4337#safe-webauthn-shared-signer)

##### Safe WebAuthn Shared Signer

There is one notable caveat when using the passkey module with ERC-4337 specifically, which is that ERC-4337 user operations can only deploy exactly one CREATE2 contract whose address matches the sender of the user operation. This means that deploying both the Safe account and its WebAuthn credential owner in a user operation's initCode is not possible.

In order to by pass this limitation you can use the SafeWebAuthnSharedSigner: a singleton that can be used as a Safe owner.

For more Infos : [Safe passkey module](https://github.com/safe-global/safe-modules/blob/main/modules/passkey/contracts/4337/README.md#overview)

```swift
import swift4337
let domain = "sample4337.cometh.io"

let signer = try await SafePasskeySigner(domain:domain, name:"UserName")
let smartAccount = try await SafeAccount(signer: signer, rpc: rpc, bundler: bundler)

```

This will init a safe with a Passkey Signer using the Safe WebAuthn Shared Signer contract as owner.
When deploying the safe, the Safe WebAuthn Shared Signer will be configured with the x and y of the passkey used.

##### Safe WebAuthn Signer

> [!IMPORTANT]  
> This configuration of Passkey signer should not be used for an undeployed safe, or the signer contract should have already been deployed. Due to 4337 limitations, only one CREATE2 contract should be deployed by the init code. Safe and signer cannot be deployed simultaneously.

```swift
import swift4337
let domain = "sample4337.cometh.io"

let keyStorage = EthereumKeyLocalStorage()
let signer = try EthereumAccount.create(replacing: keyStorage, keystorePassword: "MY_PASSWORD")
var smartAccount = try await SafeAccount(signer: signer, rpc: rpc, bundler: bundler)
let smartAccountAddress = smartAccount.address

// This will create the passkey and initialize the signer with the address calculated by the factory
let signerPasskey = try await SafePasskeySigner(domain: domain, name: "New", isSharedWebauthnSigner: false, rpc: rpc)

// This will deploy the Safe Webauthn Contract and add its address as the owner of the safe
let userOpHash = try await smartAccount.deployAndEnablePasskeySigner(x: signerPasskey.publicX, y: signerPasskey.publicY)

// Now you can use the passkey signer with the safe. Specify the address of the smart account to use the same instance. Otherwise, it will calculate a new safe address based on the signer address
smartAccount = try await SafeAccount(address: smartAccountAddress, signer: signerPasskey, rpc: rpc, bundler: bundler)
```

#### EOA Signer

Create an instance of EthereumAccount with an EthereumKeyStorage provider.

**NOTE: We recommend implementing your own KeyStorage provider instead of relying on the provided EthereumKeyLocalStorage class. The provided class is only an example conforming to the EthereumSingleKeyStorageProtocol. For more details check [web3.swift repository](https://github.com/argentlabs/web3.swift)**.

```swift
import web3

// This is just an example. EthereumKeyLocalStorage should not be used in production code
let keyStorage = EthereumKeyLocalStorage()
let eoaSigner = try EthereumAccount.create(replacing: keyStorage, keystorePassword: "MY_PASSWORD").getSigner()
```

### RPC

To interact with the blockchain and call methods on smart contracts, you need an RPC.

```swift
guard let clientUrl = URL(string: "https://an-infura-or-similar-url.com/123") else { return }
let client = EthereumHttpClient(url: clientUrl)
```

All available methods are [here](https://github.com/argentlabs/web3.swift/blob/develop/web3swift/src/Client/Protocols/EthereumClientProtocol.swift).

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


### Recovery module

#### Enable Recovery Module

Swift4337 provides a high-level API to enable the recovery module for a Safe Account.

Here is the API we provide:

```swift
func enableRecoveryModule(guardianAddress: EthereumAddress, recoveryModuleConfig: RecoveryModuleConfig = RecoveryModuleConfig()): String
func getCurrentGuardian(delayAddress: EthereumAddress): EthereumAddress?
func isRecoveryStarted(delayAddress: EthereumAddress): Bool
func cancelRecovery(delayAddress: EthereumAddress): String
```

- **enableRecoveryModule**: Enables the recovery module for the safe account by passing the guardian address and the recovery module configuration.
- **getCurrentGuardian**: Returns the current guardian address (if any) for the delay module.
- **isRecoveryStarted**: Returns true if the recovery process has started.
- **cancelRecovery**: Cancels the recovery process (if any).

`RecoveryModuleConfig` describes the configuration used for the recovery module, we provides default values:

Here are the default values used for the recovery module, use `RecoveryModuleConfig.defaultConfig()` to get the default values.

```swift
  public static func defaultConfig() -> RecoveryModuleConfig{
      return RecoveryModuleConfig(moduleFactoryAddress: "0x000000000000aDdB49795b0f9bA5BC298cDda236",
                                  delayModuleAddress: "0xd54895B1121A2eE3f37b502F507631FA1331BED6",
                                  recoveryCooldown: 86400,
                                  recoveryExpiration: 604800
      )
  }
```


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
