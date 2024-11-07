//
//  SmartAccountProtocol.swift
//  Test4337Wallet
//
//  Created by Frederic DE MATOS on 13/06/2024.
//

import Foundation
import web3
import BigInt
import os

public enum SmartAccountError: Error, Equatable {
    case errorGeneratingCallData
    case errorPredictingAddress
    case errorGettingInitCode
    case errorAccountNotDeployed
    case errorUnsupportedSigner
}

public struct EIP712Domain {
    public var chainId: Int
    public var verifyingContract: String
    
    init(chainId: Int, verifyingContract: String) {
        self.chainId = chainId
        self.verifyingContract = verifyingContract
    }
}

public protocol SmartAccountProtocol {
    
    var address: EthereumAddress {get}
    var signer: SignerProtocol {get}
    var gasEstimator: GasEstimatorProtocol {get}
    
    var rpc: EthereumRPCProtocol {get}
    var bundler: BundlerClientProtocol {get}
    var paymaster: PaymasterClientProtocol? {get}

    var chainId: Int {get}
    var entryPointAddress: EthereumAddress {get}
    
    // Methods already implemented by SmartAccountProtocol (see extension below)
    func prepareUserOperation(to: EthereumAddress, value: BigUInt, data: Data, delegateCall: Bool) async throws -> UserOperation
    func sendUserOperation(to: EthereumAddress, value: BigUInt, data: Data, delegateCall: Bool) async throws -> String
    func isDeployed() async throws -> Bool
    func getNonce(key: BigUInt) async throws -> BigUInt
   
    // Methods to be implemented for each type of smart account
    func getFactoryAddress() -> EthereumAddress
    func getFactoryData() async throws -> Data
    func getCallData(to: EthereumAddress, value:BigUInt, data:Data, delegateCall: Bool) throws -> Data
    func getOwners() async throws -> [EthereumAddress]
    func signUserOperation(_ userOperation: UserOperation) async throws -> Data
    func deployAndEnablePasskeySigner(x:BigUInt, y:BigUInt) async throws -> String 
    func addOwner(address: EthereumAddress) async throws -> String
}

extension SmartAccountProtocol{
    
    public func getNonce(key: BigUInt = BigUInt(0)) async throws -> BigUInt {
        let entryPoint = EntryPoint(client: self.rpc, address: self.entryPointAddress)
        let nonce = try await entryPoint.getNonce(sender: self.address, key: BigUInt(0))
     
        return nonce
    }
    
    public func isDeployed() async throws -> Bool{
        let code = try await self.rpc.eth_getCode(address: self.address )
        return code != "0x"
    }
    
    public func prepareUserOperation(to: EthereumAddress, value: BigUInt = BigUInt(0), data: Data = Data(), delegateCall: Bool = false) async throws -> UserOperation{
        let callData = try self.getCallData(to: to, value: value, data: data, delegateCall: delegateCall)
        let nonce = try await self.getNonce()
        
        var factory:String?
        var factoryData:String?
        if (try await self.isDeployed() ==  false) {
            factory = self.getFactoryAddress().toChecksumAddress()
            factoryData = try await self.getFactoryData().web3.hexString
        }
        var userOperation = UserOperation(sender: self.address.toChecksumAddress(),
                                          nonce: nonce.web3.hexString,
                                          factory: factory,
                                          factoryData: factoryData,
                                          callData: callData.web3.hexString,
                                          signature: try signer.dummySignature())
        
        let gasFee = try await gasEstimator.getGasFees()
        
        userOperation.maxFeePerGas = gasFee.maxFeePerGas.web3.hexString
        userOperation.maxPriorityFeePerGas = gasFee.maxPriorityFeePerGas.web3.hexString
        
        let estimation = try await bundler.eth_estimateUserOperationGas(userOperation, entryPoint:  self.entryPointAddress)
        userOperation.preVerificationGas = estimation.preVerificationGas
        userOperation.verificationGasLimit = estimation.verificationGasLimit
        userOperation.callGasLimit =  estimation.callGasLimit
        
        if let sponsorData = try await paymaster?.pm_sponsorUserOperation(userOperation, entryPoint: self.entryPointAddress) {
            userOperation.paymaster = sponsorData.paymaster
            userOperation.paymasterData = sponsorData.paymasterData
            userOperation.paymasterVerificationGasLimit = sponsorData.paymasterVerificationGasLimit
            userOperation.paymasterPostOpGasLimit = sponsorData.paymasterPostOpGasLimit
            
            if let preVerificationGas = sponsorData.preVerificationGas {
                userOperation.preVerificationGas = preVerificationGas
            }
            
            if let verificationGasLimit = sponsorData.verificationGasLimit {
                userOperation.verificationGasLimit = verificationGasLimit
            }
            
            if let callGasLimit = sponsorData.callGasLimit {
                userOperation.callGasLimit = callGasLimit
            }
      
        }
        
        return userOperation
    }

    
    public func sendUserOperation(to: EthereumAddress, value: BigUInt = BigUInt(0), data: Data = Data(), delegateCall: Bool = false) async throws -> String{
        var userOperation = try await self.prepareUserOperation(to: to, value: value, data: data, delegateCall: delegateCall)
        userOperation.signature = try await self.signUserOperation(userOperation).web3.hexString
        return try await self.bundler.eth_sendUserOperation(userOperation, entryPoint: self.entryPointAddress)
    }
    
}
