import Foundation
import ImmutableXCore
import ImmutableXWalletSDK

enum SellState {
    case loading
    case error
    case loaded(assets: [AssetDS], balance: String)
}

@MainActor
final class SellViewModel: ObservableObject {
    @Published var state: SellState = .loading
    @Published var errorAlert: ImmutableXError?

    private let wallet: ImmutableXWallet = .shared

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

            let address = try await wallet.getWalletAddress().orThrowIfNil()

            async let reponse = try await AssetsAPI.listAssets(
                pageSize: 50,
                orderBy: .name,
                direction: "asc",
                user: address,
                status: "imx",
                sellOrders: true,
                buyOrders: false,
                includeFees: true
            )

            async let balances = try await BalancesAPI.listBalances(owner: address)

            try await state = .loaded(
                assets: parse(reponse.result),
                balance: Converter.convertToEther(balances.result.first?.balance) ?? "..."
            )
        } catch {
            errorAlert = error as? ImmutableXError
            state = .error
        }
    }

    private func parse(_ assets: [AssetWithOrders]) throws -> [AssetDS] {
        try assets
            .filter { $0.name != nil }
            .map {
                var sellOrders: [OrderSellResponse] = []
                var price: String?

                if let orders = $0.orders?.sellOrders {
                    sellOrders = try JSONDecoder().decode([OrderSellResponse].self, from: JSONEncoder().encode(orders))
                }

                if let sellOrder = sellOrders.first {
                    price = Converter.formatPrice(
                        quantity: sellOrder.buyQuantity,
                        decimal: sellOrder.buyDecimals
                    )
                }

                return AssetDS(
                    name: $0.name!,
                    collectionName: $0.collection.name,
                    imageUrl: $0.imageUrl,
                    sellPrice: price,
                    tokenId: $0.tokenId,
                    tokenAddress: $0.tokenAddress,
                    orderId: sellOrders.first?.orderId
                )
            }
    }
}
