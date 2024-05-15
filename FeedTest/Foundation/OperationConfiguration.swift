import Foundation
import HTTPTypes

public struct OperationConfiguration {
    let host: String?
    let resource: String
    let method: HTTPRequest.Method
    
    init(host: String? = nil, resource: String, method: HTTPRequest.Method) {
        self.host = host
        self.resource = resource
        self.method = method
    }
}
