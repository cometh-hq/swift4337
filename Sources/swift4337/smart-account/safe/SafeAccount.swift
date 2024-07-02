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


public struct SafeAccount: SmartAccountProtocol  {
    public let address: EthereumAddress
    public let safeConfig: SafeConfig
    public let signer: EthereumAccount
    public let chainId: Int
    
    public let bundler: BundlerClientProtocol
    public let paymaster: PaymasterClientProtocol?
    public let rpc: EthereumRPCProtocol
  
    public var entryPointAddress: EthereumAddress
    
    public let gasEstimator: GasEstimatorProtocol
    
    public init(address: EthereumAddress? = nil, signer: EthereumAccount, rpc: EthereumRPCProtocol, bundler: BundlerClientProtocol, paymaster: PaymasterClientProtocol? = nil, safeConfig: SafeConfig = SafeConfig.entryPointV7(), gasEstimator: GasEstimatorProtocol? = nil) async throws {
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
    

    
    public func getCallData(to: EthereumAddress, value:BigUInt, data:Data) throws -> Data{
        let encoder = ExecuteUserOpFunction(contract: self.address, to: to,
                       value: value, calldata:data , operation: 0)
         
        let encodedTxCall = try encoder.transaction()
        
        guard let callData = encodedTxCall.data else {
            throw SmartAccountError.errorGeneratingCallDate
        }
        return callData
    }
    
    public func signUserOperation(_ userOperation: UserOperation) throws -> Data {
        let validAfter = BigUInt(0)
        let validUntil = BigUInt(0)
        
        let domain =  EIP712Domain(chainId: self.chainId, verifyingContract: self.safeConfig.ERC4337ModuleAddress)
        
        let data = try SafeOperation.eip712Data(domain: domain, 
                                            userOperation: userOperation,
                                            validUntil:validUntil,
                                            validAfter: validAfter, 
                                            entryPointAddress:entryPointAddress)
       
        
        
        let decoder = JSONDecoder()
        let typedData = try decoder.decode(TypedData.self, from: data)
        let signed = try self.signer.signMessage(message: typedData)
        
        let validUntilEncoded =  try ABIEncoder.encode(validUntil, uintSize: 48)
        let validAfterEncoded =  try ABIEncoder.encode(validAfter, uintSize: 48)
        
        let signaturePacked =  [validUntilEncoded.bytes, validAfterEncoded.bytes,  signed.web3.hexData!.bytes].flatMap { $0 }
        return Data(signaturePacked)
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
        let nonce = self.safeConfig.creationNonce
        
        guard let enableModulesCallData = try EnableModulesFunction(contract: EthereumAddress(self.safeConfig.safeModuleSetupAddress),
                                                                    modules: [EthereumAddress(self.safeConfig.ERC4337ModuleAddress)]).transaction().data else {
            throw SmartAccountError.errorPredictingAddress
        }
        
        guard let setupCallData = try SetupFunction(contract: EthereumAddress(self.safeConfig.safeSingletonL2),
                                                    _owners: [self.signer.address],
                                                    _threshold: BigUInt(1),
                                                    to: EthereumAddress(self.safeConfig.safeModuleSetupAddress),
                                                    calldata: enableModulesCallData,
                                                    fallbackHandler: EthereumAddress(self.safeConfig.ERC4337ModuleAddress),
                                                    paymentToken: EthereumAddress.zero,
                                                    payment: BigUInt(0),
                                                    paymentReceiver: EthereumAddress.zero
                                                                    ).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        guard let createProxyWithNonceData = try CreateProxyWithNonceFunction(contract: EthereumAddress(self.safeConfig.proxyFactory), _singleton: EthereumAddress(self.safeConfig.safeSingletonL2), initializer: setupCallData, saltNonce: nonce).transaction().data else {
            throw SmartAccountError.errorGettingInitCode
        }
        
        return createProxyWithNonceData
    }
    
    public static func predictAddress(signer: EthereumAccount, rpc: EthereumRPCProtocol, safeConfig: SafeConfig) async throws -> EthereumAddress {
        let nonce = safeConfig.creationNonce
        
        let safeProxyFactory = SafeProxyFactory(client: rpc , address: safeConfig.proxyFactory)
        let proxyCreationCode = try await safeProxyFactory.proxyCreationCode()
        
        guard let enableModulesCallData = try EnableModulesFunction(contract: EthereumAddress(safeConfig.safeModuleSetupAddress),
                                                                    modules: [EthereumAddress(safeConfig.ERC4337ModuleAddress)]).transaction().data else {
            throw SmartAccountError.errorPredictingAddress
        }
        
        guard let setupCallData = try SetupFunction(contract: EthereumAddress(safeConfig.safeSingletonL2),
                                                    _owners: [signer.address],
                                                    _threshold: BigUInt(1),
                                                    to: EthereumAddress(safeConfig.safeModuleSetupAddress),
                                                    calldata: enableModulesCallData,
                                                    fallbackHandler: EthereumAddress(safeConfig.ERC4337ModuleAddress),
                                                    paymentToken: EthereumAddress.zero,
                                                    payment: BigUInt(0),
                                                    paymentReceiver: EthereumAddress.zero
                                                                    ).transaction().data else {
            throw SmartAccountError.errorPredictingAddress
        }
        
        
        let safeSingletonL2Encoded = try ABIEncoder.encode(EthereumAddress(safeConfig.safeSingletonL2))
        let deploymentCode = [proxyCreationCode.bytes, safeSingletonL2Encoded.bytes].flatMap { $0 }

        let keccack256Setup = setupCallData.bytes.keccak256
        let nonceEncoded = try ABIEncoder.encode(nonce)
        
        let saltNonce = [keccack256Setup.bytes, nonceEncoded.bytes].flatMap { $0 }.keccak256
        
        let keccack256DeploymentCode = deploymentCode.bytes.keccak256
        
        let predictedAddress = try Create2.getCreate2Address(from: safeConfig.proxyFactory, salt: saltNonce.bytes, initCodeHash: keccack256DeploymentCode.bytes)
        return EthereumAddress(predictedAddress)
    }
 
}
