import Foundation
import ImmutableXCore
import ImmutableXWalletSDK
import SwiftUI

enum CollectionAssetState {
    case loading
    case error
    case loaded(assets: [CollectionAssetDS])
}

enum CollectionAssetAlert {
    case error
    case success

    var title: String {
        switch self {
        case .error:
            return "Something went wrong"
        case .success:
            return "Asset bought"
        }
    }
}

@MainActor
final class CollectionAssetViewModel: ObservableObject {
    @Published var alert: CollectionAssetAlert?
    @Published var state: CollectionAssetState = .loading
    @Published private(set) var isBuying: Bool = false

    private let wallet: ImmutableXWallet = .shared
    private let core: ImmutableX = .shared

    let collection: Collection

    init(collection: Collection) {
        self.collection = collection
    }

    func buyButtonTapped(_ asset: CollectionAssetDS) async {
        defer {
            isBuying = false
        }

        isBuying = true

        do {
            let signer = try await wallet.signer.orThrowIfNil()
            let starkSigner = try await wallet.starkSigner.orThrowIfNil()

            _ = try await core.buy(
                orderId: "\(asset.orderId)",
                signer: signer,
                starkSigner: starkSigner
            )

            alert = .success
        } catch {
            alert = .error
        }
    }

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

            let response = try await OrdersAPI.listOrders(
                pageSize: 100,
                orderBy: .buyQuantity,
                direction: "asc",
                status: .active,
                buyTokenType: "ETH",
                sellTokenType: "ERC721"
            )
            state = .loaded(
                assets: response.result.map {
                    CollectionAssetDS(
                        price: Converter.formatPrice(
                            quantity: $0.buy.data.quantity,
                            decimal: $0.buy.data.decimals
                        ) ?? "",
                        name: $0.sell.data.properties?.name ?? "",
                        imageUrl: $0.sell.data.properties?.imageUrl,
                        orderId: $0.orderId
                    )
                }
                .filter {
                    !$0.name.isEmpty && !$0.price.isEmpty
                }
            )
        } catch {
            alert = .error
            state = .error
        }
    }
}
