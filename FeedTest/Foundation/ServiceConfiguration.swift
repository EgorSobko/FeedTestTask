import Foundation
import HTTPTypes

public class ServiceConfiguration {
    private let endpointConfiguration: EndpointConfiguration
    
    init(endpointConfiguration: EndpointConfiguration) {
        self.endpointConfiguration = endpointConfiguration
    }
    
    func host<T: Endpoint>(for endpoint: T) -> String {
        if let host = endpointConfiguration.operations[T.name]?.host {
            return host
        } else {
            return endpointConfiguration.host
        }        
    }
    
    func resource<T: Endpoint>(for endpoint: T) -> String {
        guard let resource = endpointConfiguration.operations[T.name]?.resource else {
            fatalError("resource in not found for Endpoint for `\(endpoint)`. Here is the list of operations configured for this service:\n\(String(describing: endpointConfiguration.operations))")
        }
        
        return resource
    }
    
    func method<T: Endpoint>(for endpoint: T) -> HTTPRequest.Method {
        guard let method = endpointConfiguration.operations[T.name]?.method else {
            fatalError("HTTPMethod in missing in the OperationConfiguration for \(String(describing: endpointConfiguration.operations[T.name]))")
        }
        
        return method
    }
}

