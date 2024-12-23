import Foundation

public class UserOperationReceiptPoller {
    private let bundler: BundlerClientProtocol
    private let timeoutInSeconds: Int
    
    public init(bundler: BundlerClientProtocol, timeoutInSeconds: Int = 30) {
        self.bundler = bundler
        self.timeoutInSeconds = timeoutInSeconds
    }
    
    public func waitForReceipt(userOperationHash: String) async throws -> GetUserOperationReceiptResponse? {
        let deadline = Date().addingTimeInterval(TimeInterval(timeoutInSeconds))
        
        while Date() < deadline {
            let response = try await bundler.eth_getUserOperationReceipt(userOperationHash)
            if let resp = response {
                return resp
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        return nil
    }
}
