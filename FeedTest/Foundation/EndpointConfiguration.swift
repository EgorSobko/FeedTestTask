import Foundation

public struct EndpointConfiguration {
    public let host: String
    public let operations: [String: OperationConfiguration]
    
    public init(host: String, operations: [String: OperationConfiguration]) {
        self.host = host
        self.operations = operations
    }
}
