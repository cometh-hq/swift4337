import Foundation
import web3
import BigInt


struct SafeMessage {
    
    
    static let EIP712_SAFE_MESSAGE_TYPE = """
                        "SafeMessage":[
                           { "type":"bytes", "name":"message" }
                        ]
    """
    
    static func eip712Data(domain: EIP712Domain, message: Data) throws -> Data {
        let jsonData = """
           {
              "types":{
                 "EIP712Domain":[
                    {
                       "name":"chainId",
                       "type":"uint256"
                    },
                    {
                       "name":"verifyingContract",
                       "type":"address"
                    }
                 ],
                 \(EIP712_SAFE_MESSAGE_TYPE)
               },
              "primaryType":"SafeMessage",
              "domain":{
                 "chainId": \(domain.chainId),
                 "verifyingContract": "\(domain.verifyingContract)"
              },
              "message":{
                 "message":"\(message.web3.hexString)",
              }
           }
       """
        
        return jsonData.data(using: .utf8)!
    }
    
}
