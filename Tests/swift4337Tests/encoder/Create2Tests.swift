//
//  Create2Tests.swift
//
//
//  Created by Frederic DE MATOS on 20/06/2024.
//

import XCTest
@testable import swift4337


class Create2Tests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
     

func testCreate2AddressCase1() throws {
        let from = "0xfe58a39Fd369Ba46EAa55812b8204c54A7beCc0F";
        let salt =  "0x0d151319d893ea212488efd8bb1a22937f590e9a643b71580d52d9f73e4650e1".web3.bytesFromHex!
        let initCodeHash =  "0x44436c1b46a02af854be0490f564348d0d496483b3f6f7a9acc797d34c2cecef".web3.bytesFromHex!
        let expectedAddress = "0x5f1A74731d91Ce5eC1fdB95faFEc5E012536AEC5"
        
        let create2Address = try Create2.getCreate2Address(from:from , salt:salt , initCodeHash:initCodeHash)
        XCTAssertEqual(create2Address, expectedAddress)
    }
    
    func testCreate2AddressCase2() throws {
        let from = "0x7783047E5549d1ff83e618D1183394A1c2094e0F";
        let salt =  "0x30e301625465788bcf0e9bd6b3020028903c8295ea08d341b6fd75cb47de01c1".web3.bytesFromHex!
        let initCodeHash =  "0x42e4ee97c4339dee95e31e0a8748f14696870330c28e943facaf4d14f7a6efc3".web3.bytesFromHex!
        let expectedAddress = "0x4af51DA95CcD0832f3B7388Fe80C5D2A73e1DB86"
        
        let create2Address = try Create2.getCreate2Address(from:from , salt:salt , initCodeHash:initCodeHash)
        XCTAssertEqual(create2Address, expectedAddress)
    }
    
    func testCreate2AddressCase3() throws {
        let from = "0x9414c20c4a06ed631ec3891230f921D86E8Fff44";
        let salt =  "0xc94e7fff7da6b9eb3ccaafa4494aa381836df54991f402cbf28dc46f509619b8".web3.bytesFromHex!
        let initCodeHash =  "0x34b0393bffce3aa2914c3a58ebc008b7b6ee0d0087adaabdb4392b0a64920350".web3.bytesFromHex!
        let expectedAddress = "0x30E92CFF7A5415F7FCe87DA17913EA7095aC38d9"
        
        let create2Address = try Create2.getCreate2Address(from:from , salt:salt , initCodeHash:initCodeHash)
        XCTAssertEqual(create2Address, expectedAddress)
    }
    
    func testCreate2AddressCase4() throws {
        let from = "0x9414c20c4a06ed631ec3891230f921D86E8Fff44";
        let salt =  "0x0739aec466642fc9e3478883be0031ca61b02b4359f1797b86dfbab91c49abec".web3.bytesFromHex!
        let initCodeHash =  "0x00f024d57f82d7f2356d49090c4a235eb555e75b38458279c8eb5cf0028e15e3".web3.bytesFromHex!
        let expectedAddress = "0x5a071507d12Db92A5e3C5d56A637aFCED77A0Bb8"
        
        let create2Address = try Create2.getCreate2Address(from:from , salt:salt , initCodeHash:initCodeHash)
        XCTAssertEqual(create2Address, expectedAddress)
    }
    
    func testCreate2AddressCase5() throws {
        let from = "0x7783047E5549d1ff83e618D1183394A1c2094e0F";
        let salt =  "0x4eae35508ebae1329067689eb995775659a52bbfdc841bfae1e9d9341420b1b6".web3.bytesFromHex!
        let initCodeHash =  "0x060fded080de1265fd0e591163eae7ca0de0b3f2b1c1721cacb90231524e2c3d".web3.bytesFromHex!
        let expectedAddress = "0x711904ac42CBF8db7e85FB9F3cC9F40aAa1b27AE"
        
        let create2Address = try Create2.getCreate2Address(from:from , salt:salt , initCodeHash:initCodeHash)
        XCTAssertEqual(create2Address, expectedAddress)
    }
    
    func testCreate2AddressCase6() throws {
        let from = "0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67";
        let salt =  "0xdd4357ab477d47899a4976c44762fb59931767bbf890f6be804e42a975c49cb8".web3.bytesFromHex!
        let initCodeHash =  "0xe298282cefe913ab5d282047161268a8222e4bd4ed106300c547894bbefd31ee".web3.bytesFromHex!
        let expectedAddress = "0x2142Dd0E494701E2e2D4660C63569F510e3A7DF8"
        
        let create2Address = try Create2.getCreate2Address(from:from , salt:salt , initCodeHash:initCodeHash)
        XCTAssertEqual(create2Address, expectedAddress)
        
    }
}
