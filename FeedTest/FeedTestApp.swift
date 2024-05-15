import SwiftUI

@main
struct FeedTestApp: App {
    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: feedViewModel())
        }
    }
    
    private func feedViewModel() -> FeedViewModel {
        let feedRemoteService = FeedServiceFactory().make()
        
        return .init(feedRemoteService: feedRemoteService)
    }
}
