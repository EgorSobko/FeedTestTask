import Foundation
import SwiftUI

private enum Constants {
    static let swipeEndThreshold: CGFloat = 40
    static let verticalMovementThreshold: CGFloat = 10
}

enum FeedViewModelEvent {
    case onAppear
    case swipeEnded(currentDTO: FeedItemViewDTO, value: DragGesture.Value)
    case swipeInProgress(currentDTO: FeedItemViewDTO, value: DragGesture.Value)
}

class FeedViewModel: ObservableObject {
    
    @Published var feedItemsDTOs: [FeedItemViewDTO] = []
    @Published var scrollPosition: FeedItemViewDTO?
    @Published var notifications: [FeedItemViewDTO: String] = [:]

    private let feedRemoteService: FeedRemoteService
    private var feedItems: [FeedItem] = []
    
    init(feedRemoteService: FeedRemoteService) {
        self.feedRemoteService = feedRemoteService
    }
    
    func receive(_ event: FeedViewModelEvent) {
        switch event {
        case .onAppear:
            getFeed()
        case .swipeEnded(let currentDTO, let value):
            notifications[currentDTO] = nil
            let diff = abs(value.location.y - value.startLocation.y)
            guard diff > Constants.swipeEndThreshold else { return }
            
            scrollToNext(from: currentDTO)
        case .swipeInProgress(let currentDTO, let value):
            let diffY = abs(value.startLocation.y - value.location.y)
            let translationY = value.startLocation.y - value.location.y
            guard diffY > Constants.verticalMovementThreshold else {
                DispatchQueue.main.async {
                    self.notifications[currentDTO] = nil
                }
                return
            }
            
            let notification: String
            if translationY < 0 { // swipe down
                notification = "DOWN"
            } else { // swipe up
                notification = "DATE"
            }
            DispatchQueue.main.async {
                self.notifications[currentDTO] = notification
            }
        }
    }
    
    private func scrollToNext(from currentDTO: FeedItemViewDTO) {
        guard let currentIndex = feedItemsDTOs.firstIndex(of: currentDTO) else { return }
        
        let nextIndex = feedItemsDTOs.index(after: currentIndex)
        let indexToScroll = min(feedItemsDTOs.count - 1, nextIndex)
        self.scrollPosition = feedItemsDTOs[indexToScroll]
    }
    
    private func getFeed() {
        Task {
            do {
                let feedItems = try await feedRemoteService.getFeed()
                self.feedItems = feedItems
                let feedItemsDTOs: [FeedItemViewDTO] = feedItems.compactMap { item in
                    guard let userId = item.userId else { return nil }
                    
                    let nameAndAge = [
                        item.name,
                        item.age.flatMap({"\($0)"})
                    ]
                        .compactMap({ $0 })
                        .joined(separator: " * ")
                    
                    return FeedItemViewDTO(userId: userId,
                                           photoURL: item.profilePicUrl,
                                           nameAndAge: nameAndAge,
                                           location: item.loc ?? "")
                }
                
                await MainActor.run {
                    self.feedItemsDTOs = feedItemsDTOs
                    self.scrollPosition = feedItemsDTOs.first
                }
            } catch {
                await MainActor.run {
                    feedItems = []
                }
            }
        }
    }
}
