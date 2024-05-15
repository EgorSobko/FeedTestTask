import Foundation
import HTTPTypes

public struct QueryParameter {
    public let name: String
    public let value: String?
}

public protocol Endpoint {
    associatedtype ReturnType: Decodable
    associatedtype ErrorType: Error
    
    func headers() -> HTTPFields
    func queryParameters() -> [QueryParameter]?
    func httpBody() -> Data?
}

extension Endpoint {
    static var name: String {
        return String(describing: self)
    }
    
    func headers() -> HTTPFields {
        var headers = HTTPFields()
        headers.append(.init(name: .accept, value: "application/json"))
        return headers
    }
    
    func queryParameters() -> [QueryParameter]? {
        return nil
    }
    
    func httpBody() -> Data? {
        return nil
    }
}
