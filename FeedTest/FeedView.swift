import SwiftUI

private enum Constants {
    static let horizontalScrollingAnimationDuration: CGFloat = 0.2
    static let verticalScrollingAnimationDuration: CGFloat = 0.1
    static let verticalSwipeTranslationThreshold: CGFloat = 70
    static let feedImagePadding: CGFloat = 20
    static let feedImageRounding: CGFloat = 25
    static let feedItemVerticalAspect: CGFloat = 0.8
    static let metadataPadding: CGFloat = 10
}

struct FeedItemViewDTO: Hashable {
    let userId: Int
    let photoURL: URL?
    let nameAndAge: String
    let location: String
}

struct FeedView: View {
    
    @StateObject private var viewModel: FeedViewModel
    @State private var position = CGSize.zero
    @GestureState private var dragOffset: [FeedItemViewDTO: CGSize] = [:]
    
    init(viewModel: FeedViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        feedView
            .onAppear {
                viewModel.receive(.onAppear)
            }
    }
    
    private var feedView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(viewModel.feedItemsDTOs, id: \.self) { feedItemDTO in
                    feedItemView(with: feedItemDTO)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $viewModel.scrollPosition)
        .animation(.linear(duration: Constants.horizontalScrollingAnimationDuration), value: viewModel.scrollPosition)
        .scrollTargetBehavior(.viewAligned)
    }
    
    @ViewBuilder
    private func feedItemView(with feedItemDTO: FeedItemViewDTO) -> some View {
        metadataFeedItemView(with: feedItemDTO)
        .overlay {
           metadataFeedItemOverlay(with: feedItemDTO)
        }
        .background(
            metadataFeedItemBackground(with: feedItemDTO)
        )
        .offset(dragOffset[feedItemDTO] ?? .zero)
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onEnded { value in
                    viewModel.receive(.swipeEnded(currentDTO: feedItemDTO, value: value))
                }
                .updating($dragOffset) { (value, state, transaction) in
                    let cachedValue = state[feedItemDTO, default: .zero]
                    let threshold = Constants.verticalSwipeTranslationThreshold
                    let translation = max(-threshold, min(value.translation.height, threshold))
                    state[feedItemDTO] = .init(width: cachedValue.width, height: translation)
                    viewModel.receive(.swipeInProgress(currentDTO: feedItemDTO, value: value))
                }
        )
        .animation(.linear(duration: Constants.verticalScrollingAnimationDuration), value: dragOffset)
    }
    
    @ViewBuilder
    private func metadataFeedItemView(with feedItemDTO: FeedItemViewDTO) -> some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text(feedItemDTO.nameAndAge)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text(feedItemDTO.location)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(Constants.feedImagePadding + Constants.metadataPadding)
        }
        .containerRelativeFrame([.horizontal, .vertical], alignment: .center) { length, axis in
            if axis == .vertical {
                return length * Constants.feedItemVerticalAspect
            } else {
                return length
            }
        }
    }
    
    @ViewBuilder
    private func metadataFeedItemOverlay(with feedItemDTO: FeedItemViewDTO) -> some View {
        if let text = viewModel.notifications[feedItemDTO] {
            Text(text)
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private func metadataFeedItemBackground(with feedItemDTO: FeedItemViewDTO) -> some View {
        GeometryReader { proxy in
            AsyncImage(
                url: feedItemDTO.photoURL,
                content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                },
                placeholder: {
                    ProgressView()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            )
            .frame(width: proxy.size.width)
            .clipShape(RoundedRectangle(cornerRadius: Constants.feedImageRounding))
        }
        .padding(.horizontal, Constants.feedImagePadding)
    }
}
