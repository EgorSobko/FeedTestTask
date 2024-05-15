import Foundation

class URLSessionRequestHandler: HTTPRequestHandler {
    private let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func handleRequest(_ urlRequest: URLRequest) async throws -> Data? {
        let (data, response) = try await urlSession.data(for: urlRequest)
       
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceTransportError.unexpected
        }
        
        if 200..<300 ~= httpResponse.statusCode {
            return data
        }
        
        throw ServiceTransportError.invalidResponse(httpURLResponse: httpResponse, errorBody: data)
    }
}
