import Foundation

public enum APIError: Error {
    case serverError(String)
    case unknownError
}

public struct DeviceData: Encodable {
    let browser: String?
    let os: String?
    let platform: String?

    public init(browser: String? = nil, os: String? = nil, platform: String? = nil) {
        self.browser = browser
        self.os = os
        self.platform = platform
    }
}

public struct InitWalletRequest: Encodable {
    let chainId: String
    let walletAddress: String
    let initiatorAddress: String
    let publicKeyId: String?
    let publicKeyX: String?
    let publicKeyY: String?
    let deviceData: DeviceData?
}

public struct InitWalletResponse: Decodable {
    public let success: Bool
    public let isNewWallet: Bool
}

public struct CreateWebAuthnSignerRequest: Encodable {
    let chainId: String
    let walletAddress: String
    let publicKeyId: String
    let publicKeyX: String
    let publicKeyY: String
    let deviceData: DeviceData
    let signerAddress: String
    let isSharedWebAuthnSigner: Bool
}

public struct GetPasskeySignersByWalletAddressResponse: Decodable {
    public let success: Bool
    public let webAuthnSigners: [WebAuthnSigner]
}

public struct WebAuthnSigner: Decodable {
    public let _id: String
    public let publicKeyId: String
    public let publicKeyX: String
    public let publicKeyY: String
    public let signerAddress: String
    public let isSharedWebAuthnSigner: Bool
}

public struct IsValidSignatureRequest: Encodable {
    let chainId: String
    let message: String
    let signature: String
}

public struct IsValidSignatureResp: Decodable {
    public let success: Bool
    public let result: Bool
}

public class ConnectApi {
    private let apiKey: String
    private var baseUrl: String
    
    public init(apiKey: String, baseUrl: String = "https://api.4337.cometh.io") {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
    }
    
    private func makeRequest<T: Decodable>(url: String, method: String, body: Encodable?, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.serverError("Invalid URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "apiKey")
        
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            guard statusCode == 200, let data = data else {
                let error = self.extractErrorBody(from: httpResponse!, data: data)
                completion(.failure(.serverError("Invalid response: \(error ?? "no error body")")))
                return
            }
            
            // data to string
            let dataString = String(data: data, encoding: .utf8)
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                debugPrint(error)
                completion(.failure(.serverError("Decoding error: \(error.localizedDescription)")))
            }
        }.resume()
    }
    
    private func extractErrorBody(from response: HTTPURLResponse, data: Data?) -> String? {
        guard let data = data else {
            return "No data in response"
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let errorMessage = json["error"] as? String {
                return errorMessage
            } else {
                return "Error: Unable to parse JSON or 'error' key not found"
            }
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
    
    public func initWallet(
        chainId: String,
        walletAddress: String,
        initiatorAddress: String,
        publicKeyId: String?,
        publicKeyX: String?,
        publicKeyY: String?,
        deviceData: DeviceData?,
        completion: @escaping (Result<InitWalletResponse, APIError>
    ) -> Void) {
        let requestBody = InitWalletRequest(
            chainId: chainId, walletAddress: walletAddress, initiatorAddress: initiatorAddress, publicKeyId: publicKeyId, publicKeyX: publicKeyX, publicKeyY: publicKeyY, deviceData: deviceData
        )
        makeRequest(url: "\(baseUrl)/wallet/init", method: "POST", body: requestBody, completion: completion)
    }
    
    public func createWebAuthnSigner(
        chainId: String,
        walletAddress: String,
        publicKeyId: String,
        publicKeyX: String,
        publicKeyY: String,
        deviceData: DeviceData,
        signerAddress: String,
        isSharedWebAuthnSigner: Bool,
        completion: @escaping (Result<Void, APIError>
    ) -> Void) {
        let url = "\(baseUrl)/webauthn-signer/create"
        let requestBody = CreateWebAuthnSignerRequest(
            chainId: chainId, walletAddress: walletAddress, publicKeyId: publicKeyId, publicKeyX: publicKeyX, publicKeyY: publicKeyY, deviceData: deviceData, signerAddress: signerAddress, isSharedWebAuthnSigner: isSharedWebAuthnSigner
        )
        makeRequest(url: url, method: "POST", body: requestBody) { (result: Result<EmptyResponse, APIError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getPasskeySignersByWalletAddress(walletAddress: String, completion: @escaping (Result<GetPasskeySignersByWalletAddressResponse, APIError>) -> Void) {
        let url = "\(baseUrl)/webauthn-signer/\(walletAddress)"
        makeRequest(url: url, method: "GET", body: nil, completion: completion)
    }
    
    public func isValidSignature(
        walletAddress: String,
        chainId: String,
        message: String,
        signature: String,
        completion: @escaping (Result<IsValidSignatureResp, APIError>
    ) -> Void) {
        let url = "\(baseUrl)/wallet/is-valid-signature/\(walletAddress)"
        makeRequest(url: url, method: "POST", body: IsValidSignatureRequest(
            chainId: chainId,
            message: message,
            signature: signature
        ), completion: completion)
    }
    
    private struct EmptyResponse: Decodable {}
}
