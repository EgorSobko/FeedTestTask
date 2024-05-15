import Foundation
import HTTPTypes
import HTTPTypesFoundation

public enum ServiceTransportError: Error {
    case invalidResponse(httpURLResponse: HTTPURLResponse?, errorBody: Data?)
    case objectMapping(error: Error)
    case unexpected
}

// Just a namespace
enum ServiceImplementation { }

open class Service {
    
    private let requestHandler: HTTPRequestHandler
    
    open var config: ServiceConfiguration {
        fatalError("Subclasses must override this property to declare their configuration.")
    }
    
    init(requestHandler: HTTPRequestHandler) {
        self.requestHandler = requestHandler
    }
    
    func request<T: Endpoint>(_ endpoint: T) async throws -> T.ReturnType {
        return try await processRequest(endpoint)
    }
    
    private func processRequest<T: Endpoint>(_ endpoint: T) async throws -> T.ReturnType {
        let theURLRequest = urlRequest(for: endpoint)
        
        let data = try await requestHandler.handleRequest(theURLRequest)
        return try mapValue(endpoint, data)
    }
    
    func urlRequest<T: Endpoint>(for endpoint: T) -> URLRequest {
        guard let baseURL = URL(string: config.host(for: endpoint)) else {
            fatalError("baseURL should be always valid")
        }
        let resource = config.resource(for: endpoint)
        
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return URLRequest(url: baseURL)
        }
        
        urlComponents.path = resource
        
        let queryItems: [URLQueryItem] = endpoint.queryParameters()?.compactMap { parameter in
            let name = parameter.name
            let value = parameter.value
            
            return URLQueryItem(name: name, value: value)
            } ?? []
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            return URLRequest(url: baseURL)
        }
        
        var httpRequest = HTTPRequest(method: config.method(for: endpoint), url: url)
        httpRequest.headerFields = endpoint.headers()
        
        guard var request = URLRequest(httpRequest: httpRequest) else {
            return URLRequest(url: baseURL)
        }
        
        if let body = endpoint.httpBody() {
            request.httpBody = body
        }
        
        return request
    }
    
    private func mapValue<T: Endpoint>(_ endpoint: T, _ responseData: Data?) throws -> T.ReturnType {
        guard let responseData = responseData else {
            throw ServiceTransportError.unexpected
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.ReturnType.self, from: responseData)
        }
        catch let decodingError as DecodingError {
            throw ServiceTransportError.objectMapping(error: decodingError)
        }
        catch {
            throw ServiceTransportError.unexpected
        }
    }
}
