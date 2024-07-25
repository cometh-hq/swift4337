//
//  EncodeWebAuthnSignatureTests.swift
//
//
//  Created by Frederic DE MATOS on 22/07/2024.
//


import XCTest
import web3
import BigInt
import AuthenticationServices

@testable import swift4337



class EncodeWebAuthnSignatureTests: XCTestCase {
    
    func testGetRSisOK() async throws {
        
        let base64Signature = URLEncodedBase64("MEQCIAZnp2j6bRUj49CFmhuHI_RKh_8puFto169kkI5mLsq8AiALHKJ9q5ogwIKKyxuA2GEyY-SAH5WIqpzoOno0T4FONQ")
        let signatureData = Data(base64Signature.decodedBytes!)
        
        let credential = WebauthnCredentialData(clientDataJSON: "0x7b2274797065223a22776562617574686e2e676574222c226368616c6c656e6765223a22675f6b447865705f5f6d48574535756642472d4c663645756461465770416466616631785473754b4f3577222c226f726967696e223a2268747470733a2f2f736166652e676c6f62616c227d".web3.hexData!,
                                                signature: signatureData,
                                                authenticatorData: "0xa24f744b28d73f066bf3203d145765a7bc735e6328168c8b03e476da3ad0d8fe0400000000".web3.hexData!)
        
        var r: BigUInt
        var s: BigUInt
        
        (r, s) = try credential.extractRS()
        
        let expectedR = "0x00667a768fa6d1523e3d0859a1b8723f44a87ff29b85b68d7af64908e662ecabc"
        let expectedS = "0x0b1ca27dab9a20c0828acb1b80d8613263e4801f9588aa9ce83a7a344f814e35"
        XCTAssertEqual(BigUInt(hex: expectedR)!, "2897017761019086211315850802666377071062063123179433583373092069011580963516")
        XCTAssertEqual(BigUInt(hex: expectedS)!, "5026034523203044929700416186392134445038023955642121016067859994151907053109")
        
        XCTAssertEqual(r, BigUInt(hex: expectedR)!)
        XCTAssertEqual(s, BigUInt(hex: expectedS)!)
        
    }
    
    func testAnotherGetRSisOK() async throws {
       
        let credential = WebauthnCredentialData(clientDataJSON: "0x7b2274797065223a22776562617574686e2e676574222c226368616c6c656e6765223a22675f6b447865705f5f6d48574535756642472d4c663645756461465770416466616631785473754b4f3577222c226f726967696e223a2268747470733a2f2f736166652e676c6f62616c227d".web3.hexData!,
                                                signature: "0x3045022100db12d599cf850e2a0fce79ff9087e2d54885115ba7de5ed58977712a864df83c022051488668759407f33488c9bd4e22b7cf4f7ba07f8e419bcb6084e4a2679bd2b9".web3.hexData!,
                                                authenticatorData: "0xa24f744b28d73f066bf3203d145765a7bc735e6328168c8b03e476da3ad0d8fe0400000000".web3.hexData!)
        
        var r: BigUInt
        var s: BigUInt
        
        (r, s) = try credential.extractRS()
        
        XCTAssertEqual(r, "99089791305599436598905838338070685807514077027175354696932704661153296283708")
        XCTAssertEqual(s, "36765481374135979018215554259021175210850879424580977969675998689329105588921")
    }
    
    func testDecodeClientDataisOK() async throws {
       
        let credential = WebauthnCredentialData(clientDataJSON: "0x7b2274797065223a22776562617574686e2e676574222c226368616c6c656e6765223a22675f6b447865705f5f6d48574535756642472d4c663645756461465770416466616631785473754b4f3577222c226f726967696e223a2268747470733a2f2f736166652e676c6f62616c227d".web3.hexData!,
                                                signature: "0x3045022100db12d599cf850e2a0fce79ff9087e2d54885115ba7de5ed58977712a864df83c022051488668759407f33488c9bd4e22b7cf4f7ba07f8e419bcb6084e4a2679bd2b9".web3.hexData!,
                                                authenticatorData: "0xa24f744b28d73f066bf3203d145765a7bc735e6328168c8b03e476da3ad0d8fe0400000000".web3.hexData!)
        
   
        
        let clientData = try credential.decodeClientDataFields()
        
        XCTAssertEqual(clientData, "\"origin\":\"https://safe.global\"")
       
    }
    
    func testEncodeWebAuthnSignatureIsOk() async throws {
        
        let credential = WebauthnCredentialData(clientDataJSON: "0x7b2274797065223a22776562617574686e2e676574222c226368616c6c656e6765223a22675f6b447865705f5f6d48574535756642472d4c663645756461465770416466616631785473754b4f3577222c226f726967696e223a2268747470733a2f2f736166652e676c6f62616c227d".web3.hexData!,
                                                signature: "0x3045022100db12d599cf850e2a0fce79ff9087e2d54885115ba7de5ed58977712a864df83c022051488668759407f33488c9bd4e22b7cf4f7ba07f8e419bcb6084e4a2679bd2b9".web3.hexData!,
                                                authenticatorData: "0xa24f744b28d73f066bf3203d145765a7bc735e6328168c8b03e476da3ad0d8fe0400000000".web3.hexData!)
        
        let expected = "0x000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000e0db12d599cf850e2a0fce79ff9087e2d54885115ba7de5ed58977712a864df83c51488668759407f33488c9bd4e22b7cf4f7ba07f8e419bcb6084e4a2679bd2b90000000000000000000000000000000000000000000000000000000000000025a24f744b28d73f066bf3203d145765a7bc735e6328168c8b03e476da3ad0d8fe0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e226f726967696e223a2268747470733a2f2f736166652e676c6f62616c220000"
        
        
        let encodedSignature = try credential.encodeWebAuthnSignature()
        
        XCTAssertEqual(encodedSignature.web3.hexString, expected)
    }
    
}
