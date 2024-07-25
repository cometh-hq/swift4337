import Foundation

public enum AttestationFormat: String, RawRepresentable, Equatable, Sendable {
    case packed
    case tpm
    case androidKey = "android-key"
    case androidSafetynet = "android-safetynet"
    case fidoU2F = "fido-u2f"
    case apple
    case none
}

public struct VerifiedAuthentication: Sendable {
    public enum CredentialDeviceType: String, Sendable {
        case singleDevice = "single_device"
        case multiDevice = "multi_device"
    }

    /// The credential id associated with the public key
    public let credentialID: URLEncodedBase64
    /// The updated sign count after the authentication ceremony
    public let newSignCount: UInt32
    /// Whether the authenticator is a single- or multi-device authenticator. This value is determined after
    /// registration and will not change afterwards.
    public let credentialDeviceType: CredentialDeviceType
    /// Whether the authenticator is known to be backed up currently
    public let credentialBackedUp: Bool
}


struct AuthenticatorFlags: Equatable {

    /**
     Taken from https://w3c.github.io/webauthn/#sctn-authenticator-data
     Bit 0: User Present Result
     Bit 1: Reserved for future use
     Bit 2: User Verified Result
     Bits 3-5: Reserved for future use
     Bit 6: Attested credential data included
     Bit 7: Extension data include
     */

    enum Bit: UInt8 {
        case userPresent = 0
        case userVerified = 2
        case backupEligible = 3
        case backupState = 4
        case attestedCredentialDataIncluded = 6
        case extensionDataIncluded = 7
    }

    let userPresent: Bool
    let userVerified: Bool
    let isBackupEligible: Bool
    let isCurrentlyBackedUp: Bool
    let attestedCredentialData: Bool
    let extensionDataIncluded: Bool

    var deviceType: VerifiedAuthentication.CredentialDeviceType {
        isBackupEligible ? .multiDevice : .singleDevice
    }

    static func isFlagSet(on byte: UInt8, at position: Bit) -> Bool {
        (byte & (1 << position.rawValue)) != 0
    }
}

extension AuthenticatorFlags {
    init(_ byte: UInt8) {
        userPresent = Self.isFlagSet(on: byte, at: .userPresent)
        userVerified = Self.isFlagSet(on: byte, at: .userVerified)
        isBackupEligible = Self.isFlagSet(on: byte, at: .backupEligible)
        isCurrentlyBackedUp = Self.isFlagSet(on: byte, at: .backupState)
        attestedCredentialData = Self.isFlagSet(on: byte, at: .attestedCredentialDataIncluded)
        extensionDataIncluded = Self.isFlagSet(on: byte, at: .extensionDataIncluded)
    }
}

public enum Endian {
    case big, little
}

protocol IntegerTransform: Sequence where Element: FixedWidthInteger {
    func toInteger<I: FixedWidthInteger>(endian: Endian) -> I
}

extension IntegerTransform {
    func toInteger<I: FixedWidthInteger>(endian: Endian) -> I {
        // swiftlint:disable:next identifier_name
        let f = { (accum: I, next: Element) in accum &<< next.bitWidth | I(next) }
        return endian == .big ? reduce(0, f) : reversed().reduce(0, f)
    }
}

extension Data: IntegerTransform {}
extension Array: IntegerTransform where Element: FixedWidthInteger {}



struct AttestedCredentialData: Equatable {
    let aaguid: [UInt8]
    let credentialID: [UInt8]
    let publicKey: [UInt8]
}

/// Data created and/ or used by the authenticator during authentication/ registration.
/// The data contains, for example, whether a user was present or verified.
struct AuthenticatorData {
    let relyingPartyIDHash: [UInt8]
    let flags: AuthenticatorFlags
    let counter: UInt32
    /// For attestation signatures this value will be set. For assertion signatures not.
    let attestedData: AttestedCredentialData?
    let extData: [UInt8]?
}

extension AuthenticatorData {
    init(bytes: Data) throws {
        let minAuthDataLength = 37
        guard bytes.count >= minAuthDataLength else {
            throw WebAuthnError.authDataTooShort
           
        }

        let relyingPartyIDHash = Array(bytes[..<32])
        let flags = AuthenticatorFlags(bytes[32])
        let counter: UInt32 = Data(bytes[33..<37]).toInteger(endian: .big)

        var remainingCount = bytes.count - minAuthDataLength

        var attestedCredentialData: AttestedCredentialData?
        // For attestation signatures, the authenticator MUST set the AT flag and include the attestedCredentialData.
        if flags.attestedCredentialData {
            let minAttestedAuthLength = 55
            guard bytes.count > minAttestedAuthLength else {
                throw WebAuthnError.attestedCredentialDataMissing
        
            }
            let (data, length) = try Self.parseAttestedData(bytes)
            attestedCredentialData = data
            remainingCount -= length
        // For assertion signatures, the AT flag MUST NOT be set and the attestedCredentialData MUST NOT be included.
        } else {
            if !flags.extensionDataIncluded && bytes.count != minAuthDataLength {
                throw WebAuthnError.attestedCredentialFlagNotSet
 
            }
        }

        var extensionData: [UInt8]?
        if flags.extensionDataIncluded {
            guard remainingCount != 0 else {
                throw WebAuthnError.extensionDataMissing

            }
            extensionData = Array(bytes[(bytes.count - remainingCount)...])
            remainingCount -= extensionData!.count
        }

        guard remainingCount == 0 else {
            throw WebAuthnError.leftOverBytesInAuthenticatorData

        }

        self.relyingPartyIDHash = relyingPartyIDHash
        self.flags = flags
        self.counter = counter
        self.attestedData = attestedCredentialData
        self.extData = extensionData

    }

    /// Returns: Attested credentials data and the length
    private static func parseAttestedData(_ data: Data) throws -> (AttestedCredentialData, Int) {
        // We've parsed the first 37 bytes so far, the next bytes now should be the attested credential data
        // See https://w3c.github.io/webauthn/#sctn-attested-credential-data
        let aaguidLength = 16
        let aaguid = data[37..<(37 + aaguidLength)]  // To byte at index 52

        let idLengthBytes = data[53..<55]  // Length is 2 bytes
        let idLengthData = Data(idLengthBytes)
        let idLength: UInt16 = idLengthData.toInteger(endian: .big)
        let credentialIDEndIndex = Int(idLength) + 55

        guard data.count >= credentialIDEndIndex else {
            throw WebAuthnError.credentialIDTooShort
        }
        let credentialID = data[55..<credentialIDEndIndex]
        let publicKeyBytes = data[credentialIDEndIndex...]

        let data = AttestedCredentialData(
            aaguid: Array(aaguid),
            credentialID: Array(credentialID),
            publicKey: Array(publicKeyBytes)
        )

        // 2 is the bytes storing the size of the credential ID
        let length = data.aaguid.count + 2 + data.credentialID.count + data.publicKey.count

        return (data, length)
    }
}
