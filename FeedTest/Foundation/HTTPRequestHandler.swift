import Foundation

public protocol HTTPRequestHandler {
    func handleRequest(_ urlRequest: URLRequest) async throws -> Data?
}
