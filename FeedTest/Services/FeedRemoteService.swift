import Foundation

protocol FeedRemoteService {
    func getFeed() async throws -> [FeedItem]
}

class FeedServiceFactory {
    
    public init() { }
    
    public func make() -> FeedRemoteService {
        let configuration = URLSessionConfiguration.default
        let requestHandler = URLSessionRequestHandler(urlSession: URLSession(configuration: configuration))
        
        return ServiceImplementation.FeedService(requestHandler: requestHandler)
    }
}

private extension ServiceImplementation {
    
    class FeedService: Service, FeedRemoteService {
        
        override public var config: ServiceConfiguration {
            return ServiceConfiguration(
                endpointConfiguration: EndpointConfiguration(
                    host: "https://raw.githubusercontent.com",
                    operations: [
                        GetFeed.name: OperationConfiguration(resource: "/downapp/sample/main/sample.json", method: .get)
                    ])
            )
        }
        
        func getFeed() async throws -> [FeedItem] {
            return try await request(GetFeed())
        }
        
        private struct GetFeed: Endpoint {
            typealias ReturnType = [FeedItem]
            typealias ErrorType = ServiceTransportError
        }
    }
}
