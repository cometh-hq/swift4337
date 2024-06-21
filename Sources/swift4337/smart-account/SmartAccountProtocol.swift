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
    case errorGeneratingCallDate
    case errorPredictingAddress
    case errorGettingInitCode
    case errorAccountNotDeployed
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
    var signer: EthereumAccount {get}
    
    var rpc: EthereumRPCProtocol {get}
    var bundler: BundlerClientProtocol {get}
    var paymaster: PaymasterClientProtocol? {get}

    var chainId: Int {get}
    var entryPointAddress: EthereumAddress {get}
   
    func getInitCode() async throws -> Data
    func getCallData(to: EthereumAddress, value:BigUInt, data:Data) throws -> Data
    func getNonce(key: BigUInt) async throws -> BigUInt
    func getOwners() async throws -> [EthereumAddress]
    func signUserOperation(_ userOperation: UserOperation) throws -> Data
    
    func prepareUserOperation(to: EthereumAddress, value: BigUInt, data: Data) async throws -> UserOperation
    func sendUserOperation(to: EthereumAddress, value: BigUInt, data: Data) async throws -> String
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
    
    public func prepareUserOperation(to: EthereumAddress, value: BigUInt = BigUInt(0), data: Data = Data()) async throws -> UserOperation{
        let callData = try self.getCallData(to: to, value: value, data: data)
        let nonce = try await self.getNonce()
        
        var initCode = Data()
        if (try await self.isDeployed() ==  false) {
            initCode = try await self.getInitCode()
        }
        var userOperation = UserOperation(sender: self.address.toChecksumAddress(),
                                          nonce: nonce.web3.hexString,
                                          initCode: initCode.web3.hexString,
                                          callData: callData.web3.hexString)
        
        let gasEstimator = RPCGasEstimator(self.rpc)
        let gasFee = try await gasEstimator.getGasFees()
        
        userOperation.maxFeePerGas = gasFee.maxFeePerGas.web3.hexString
        userOperation.maxPriorityFeePerGas = gasFee.maxPriorityFeePerGas.web3.hexString
        
        let estimation = try await bundler.eth_estimateUserOperationGas(userOperation, entryPoint:  self.entryPointAddress)
        userOperation.preVerificationGas = estimation.preVerificationGas
        userOperation.verificationGasLimit = estimation.verificationGasLimit
        userOperation.callGasLimit =  estimation.callGasLimit
        
        if let sponsorData = try await paymaster?.pm_sponsorUserOperation(userOperation, entryPoint: self.entryPointAddress) {
            userOperation.paymasterAndData = sponsorData.paymasterAndData
            userOperation.callGasLimit = sponsorData.callGasLimit
            userOperation.preVerificationGas = sponsorData.preVerificationGas
            userOperation.verificationGasLimit = sponsorData.verificationGasLimit
        }
        
        return userOperation
    }

    
    public func sendUserOperation(to: EthereumAddress, value: BigUInt = BigUInt(0), data: Data = Data()) async throws -> String{
        var userOperation = try await self.prepareUserOperation(to: to, value: value, data: data)
        userOperation.signature = try self.signUserOperation(userOperation).web3.hexString
        return try await self.bundler.eth_sendUserOperation(userOperation, entryPoint: self.entryPointAddress)
    }
    
}
