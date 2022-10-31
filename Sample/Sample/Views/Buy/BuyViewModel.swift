import Foundation
import ImmutableXCore

extension Collection: Identifiable {
    public var id: String {
        address
    }
}

enum BuyState {
    case loading
    case error
    case loaded(collections: [Collection])
}

@MainActor
final class BuyViewModel: ObservableObject {
    @Published var state: BuyState = .loading
    @Published var errorAlert: ImmutableXError?

    func onAppear() async {
        await loadScreen(shouldTriggerLoading: true)
    }

    func retryButtonTapped() async {
        await loadScreen(shouldTriggerLoading: true)
    }

    func pullToRefreshTriggered() async {
        await loadScreen(shouldTriggerLoading: false)
    }

    private func loadScreen(shouldTriggerLoading: Bool) async {
        do {
            if shouldTriggerLoading {
                state = .loading
            }

            let response = try await CollectionsAPI.listCollections(pageSize: 100)
            state = .loaded(collections: response.result)
        } catch {
            errorAlert = error as? ImmutableXError
            state = .error
        }
    }
}
