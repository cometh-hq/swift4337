//
//  SmartAccount.swift
//  Test4337Wallet
//
//  Created by Frederic DE MATOS on 10/06/2024.
//
import Foundation
import web3
import BigInt
import os

// safe account error
enum SafeAccountError: Error {
    case errorCannotDeployRecoveryModule
    case errorRecoveryModuleAlreadyDeployed
    case errorRecoveryModuleNotDeployed
    case errorRecoveryNotStarted
}


public struct SafeAccount: SmartAccountProtocol  {

    
    
    
    public let address: EthereumAddress
    public let safeConfig: SafeConfig
    public let signer: SignerProtocol
    public let chainId: Int
    
    public let bundler: BundlerClientProtocol
    public let paymaster: PaymasterClientProtocol?
    public let rpc: EthereumRPCProtocol
  
    public var entryPointAddress: EthereumAddress
    
    public let gasEstimator: GasEstimatorProtocol
    
    public init(address: EthereumAddress? = nil, signer: SignerProtocol, rpc: EthereumRPCProtocol, bundler: BundlerClientProtocol, paymaster: PaymasterClientProtocol? = nil, safeConfig: SafeConfig = SafeConfig.entryPointV7(), gasEstimator: GasEstimatorProtocol? = nil) async throws {
        if let address {
            self.address = address
        } else {
            self.address = try await SafeAccount.predictAddress(signer: signer, rpc: rpc, safeConfig: safeConfig)
        }
        self.signer = signer
        self.safeConfig = safeConfig
        
        self.rpc = rpc
        self.bundler = bundler
        self.paymaster = paymaster
        
        self.chainId = rpc.network.intValue
        
        self.entryPointAddress = EthereumAddress(self.safeConfig.entryPointAddress)
        
        if let estimator = gasEstimator{
            self.gasEstimator = estimator
        } else {
            self.gasEstimator = RPCGasEstimator(rpc)
        }
            
        
    }
    

    public func getCallData(to: EthereumAddress, value:BigUInt, data:Data, delegateCall: Bool) throws -> Data{
        let encoder = ExecuteUserOpFunction(contract: self.address, to: to,
                                            value: value, calldata:data , operation: delegateCall ? 1 : 0 )
         
        let encodedTxCall = try encoder.transaction()
        
        guard let callData = encodedTxCall.data else {
            throw SmartAccountError.errorGeneratingCallData
        }
        return callData
    }
    
    public func signUserOperation(_ userOperation: UserOperation) async throws -> Data {
        let validAfter = BigUInt(0)
        let validUntil = BigUInt(0)
        
        let domain =  EIP712Domain(chainId: self.chainId, verifyingContract: self.safeConfig.ERC4337ModuleAddress)
        
        let data = try SafeOperation.eip712Data(domain: domain, 
                                            userOperation: userOperation,
                                            validUntil:validUntil,
                                            validAfter: validAfter, 
                                            entryPointAddress:entryPointAddress)
       
        let typedData = try self.hashTypeData(data)
        let signed = try await self.signer.signMessage(message: typedData)
        
        let validUntilEncoded =  try ABIEncoder.encode(validUntil, uintSize: 48)
        let validAfterEncoded =  try ABIEncoder.encode(validAfter, uintSize: 48)
        
        let signaturePacked =  [validUntilEncoded.bytes, validAfterEncoded.bytes, signed.web3.hexData!.web3.bytes].flatMap { $0 }
        return Data(signaturePacked)
    }
    
    private func hashTypeData(_ data: Data) throws -> TypedData {
        let decoder = JSONDecoder()
        return try decoder.decode(TypedData.self, from: data)
    }
    
    public func getOwners() async throws -> [EthereumAddress] {
        guard try await self.isDeployed() else {
            throw SmartAccountError.errorAccountNotDeployed
        }
        
        let function = GetOwnersFunction(contract: self.address)
        let data = try await function.call(withClient: self.rpc, responseType: GetOwnersResponse.self)
        return data.value
    }
    
    
    public func getFactoryAddress() -> EthereumAddress {
        return EthereumAddress(self.safeConfig.proxyFactory)
    }
    
    public func getFactoryData() async throws -> Data {
        let setupCallData = try SignerUtils.setupCallData(signer: self.signer, safeConfig: self.safeConfig)
        let nonce = self.safeConfig.creationNonce
        
        guard let createProxyWithNonceData = try CreateProxyWithNonceFunction(contract: EthereumAddress(self.safeConfig.proxyFactory), _singleton: EthereumAddress(self.safeConfig.safeSingletonL2), initializer: setupCallData, saltNonce: nonce).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        return createProxyWithNonceData
    }
    
    public func addOwner(address: EthereumAddress) async throws -> String {
        guard let addOwnerData = try AddOwnerWithThresholdFunction(contract: self.address, owner: address, _threshold: BigUInt(1)).transaction().data else {
            throw  SmartAccountError.errorGeneratingCallData
        }
        
        let userOperationHash = try await self.sendUserOperation(to: self.address, data: addOwnerData)
        return userOperationHash
    }
    
    public func deployAndEnablePasskeySigner(x:BigUInt, y:BigUInt) async throws -> String {
        let verifiers = EthereumAddress(self.safeConfig.safeP256VerifierAddress).asNumber()!
        let functionGetSigner =  GetSignerFunction(contract:  EthereumAddress(safeConfig.safeWebauthnSignerFactory), x: x, y: y, verifiers: verifiers)
        let signerAddress = try await functionGetSigner.call(withClient:self.rpc , responseType: GetSignerResponse.self).value
        
        let safeWebauthnSignerFactory = EthereumAddress(self.safeConfig.safeWebauthnSignerFactory)
        
        guard let createSignerData = try CreateSignerFunction(contract:safeWebauthnSignerFactory , x: x, y: y, verifiers: verifiers).transaction().data else {
            throw  SmartAccountError.errorGeneratingCallData
        }
        
        guard let addOwnerData = try AddOwnerWithThresholdFunction(contract: self.address, owner: signerAddress, _threshold: BigUInt(1)).transaction().data else {
            throw  SmartAccountError.errorGeneratingCallData
        }
        
        let pakedMultiSend = try [MultiSendTransaction(op: BigUInt(0), to: safeWebauthnSignerFactory, data: createSignerData), MultiSendTransaction(op: BigUInt(0), to:  self.address, data: addOwnerData)].pack()
        
        
        guard let multiSendData = try MultiSendFunction(contract: EthereumAddress(safeConfig.safeMultiSendAddress), transactions: pakedMultiSend).transaction().data else {
            throw SmartAccountError.errorGeneratingCallData
        }
        
        let safeMultiSendAddress = EthereumAddress(safeConfig.safeMultiSendAddress)
        
        let userOperationHash = try await self.sendUserOperation(to: safeMultiSendAddress, data: multiSendData, delegateCall: true)
        
        return userOperationHash
    }
    
    public func sendUserOperation(_ params: [TransactionParams]) async throws -> String {
        let pakedMultiSend = try params.map { txParam in
            MultiSendTransaction(
                op: BigUInt(txParam.delegateCall ? 1 : 0),
                to: txParam.to,
                data: txParam.data
            )
        }.pack()
        guard let multiSendData = try MultiSendFunction(contract: EthereumAddress(safeConfig.safeMultiSendAddress), transactions: pakedMultiSend).transaction().data else {
            throw SmartAccountError.errorGeneratingCallData
        }
        let userOperationHash = try await self.sendUserOperation(
            to: EthereumAddress(safeConfig.safeMultiSendAddress),
            data: multiSendData,
            delegateCall: true
        )
        return userOperationHash
    }
    
    public static func predictAddress(signer: SignerProtocol, rpc: EthereumRPCProtocol, safeConfig: SafeConfig) async throws -> EthereumAddress {
        let nonce = safeConfig.creationNonce
        
        let safeProxyFactory = SafeProxyFactory(client: rpc , address: safeConfig.proxyFactory)
        let proxyCreationCode = try await safeProxyFactory.proxyCreationCode()
        
        let setupCallData = try SignerUtils.setupCallData(signer: signer, safeConfig: safeConfig)
        
        let safeSingletonL2Encoded = try ABIEncoder.encode(EthereumAddress(safeConfig.safeSingletonL2))
        let deploymentCode = [proxyCreationCode.web3.bytes, safeSingletonL2Encoded.bytes].flatMap { $0 }

        let keccack256Setup = setupCallData.web3.bytes.keccak256
        let nonceEncoded = try ABIEncoder.encode(nonce)
        let saltNonce = [keccack256Setup.web3.bytes, nonceEncoded.bytes].flatMap { $0 }.keccak256
        let keccack256DeploymentCode = deploymentCode.keccak256
        let predictedAddress = try Create2.getCreate2Address(from: safeConfig.proxyFactory, salt: saltNonce.web3.bytes, initCodeHash: keccack256DeploymentCode.web3.bytes)
        return EthereumAddress(predictedAddress)
    }
    
    public func signMessage(_ message: Data) async throws -> Data? {
        let domain =  EIP712Domain(chainId: self.chainId, verifyingContract: self.address.toChecksumAddress())
        let data = try SafeMessage.eip712Data(domain: domain, message: message)
       
        let typedData = try self.hashTypeData(data)
        let signed = try await self.signer.signMessage(message: typedData)
        return signed.web3.hexData
    }
    
    public func isValidSignature(_ message: Data, signature: Data) async throws -> Bool {
        let function = IsValidSignatureFunction(contract: self.address, message: message, signature: signature)
        let response = try await function.call(withClient: self.rpc, responseType: IsValidSignatureResponse.self)
        return response.isValid
    }
    
    // Recovery Module
    public func predictRecoveryModuleAddress(config: RecoveryModuleConfig) throws -> EthereumAddress? {
        return try DelayModuleUtils.predictAddress(safeAddress: self.address, config: config)
    }

    public func enableRecovery(guardianAddress: EthereumAddress, config: RecoveryModuleConfig) async throws -> String {
        let delayAddress = try self.predictRecoveryModuleAddress(config: config)
        guard let delayAddress else {
            throw SafeAccountError.errorCannotDeployRecoveryModule
        }
        let isDeployed = try await self.rpc.eth_getCode(address: delayAddress) != "0x"
        if isDeployed {
            throw SafeAccountError.errorRecoveryModuleAlreadyDeployed
        }

        let initializer = try DelayModuleUtils.getSetUpFunctionData(safeAddress: self.address, recoveryModuleConfig: config)

        let saltNonce = BigUInt(self.address.toChecksumAddress().web3.hexData!)
        let deployModuleCallData = try DeployModuleFunction.callData(masterCopy: EthereumAddress(config.delayModuleAddress), initializer: initializer, saltNonce: saltNonce)
        let txs: [TransactionParams] = [
            TransactionParams(to: EthereumAddress(config.moduleFactoryAddress), value: BigUInt(0), data: deployModuleCallData),
            TransactionParams(to: self.address, value: BigUInt(0), data: try EnableModuleFunction.callData(moduleAddress: delayAddress)),
            TransactionParams(to: delayAddress, value: BigUInt(0), data: try EnableModuleFunction.callData(moduleAddress: guardianAddress)),
        ]
        let userOperationHash = try await self.sendUserOperation(txs)
        return userOperationHash
    }
    
    public func getCurrentGuardian(delayAddress: EthereumAddress) async throws -> EthereumAddress? {
        let SENTINEL_MODULES = "0x0000000000000000000000000000000000000001"
        let function = GetModulesPaginatedFunction(contract: delayAddress, start: EthereumAddress(SENTINEL_MODULES), pageSize: BigUInt(1000))
        let response = try await function.call(withClient: self.rpc, responseType: GetModulesPaginatedResponse.self)
        return response.array.first
    }

    public func isRecoveryStarted(delayAddress: EthereumAddress) async throws -> Bool {
        let txNonce = try await TxNonceFunction(contract: delayAddress).call(withClient: self.rpc, responseType: TxNonceResponse.self)
        let queueNonce = try await QueueNonceFunction(contract: delayAddress).call(withClient: self.rpc, responseType: QueueNonceResponse.self)
        return queueNonce.value > txNonce.value
    }

    public func cancelRecovery(delayAddress: EthereumAddress) async throws -> String {
        let isDeployed = try await self.rpc.eth_getCode(address: delayAddress ) != "0x"
        if !isDeployed {
            throw SafeAccountError.errorRecoveryModuleNotDeployed
        }
        if try await !self.isRecoveryStarted(delayAddress: delayAddress) {
            throw SafeAccountError.errorRecoveryNotStarted
        }
        let txNonce = try await TxNonceFunction(contract: delayAddress).call(withClient: self.rpc, responseType: TxNonceResponse.self)
        let newNonce = txNonce.value + 1
        let setTxNonceCallData = try SetTxNonceFunction.callData(nonce: newNonce)
        return try await self.sendUserOperation(to: delayAddress, data: setTxNonceCallData)
    }
    
}
