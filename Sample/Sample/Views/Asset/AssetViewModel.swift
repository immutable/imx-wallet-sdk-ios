import Foundation
import ImmutableXCore
import ImmutableXWalletSDK
import SwiftUI

@MainActor
final class AssetViewModel: ObservableObject {
    @Published var errorAlert: Error?
    @Published var transferAddress: String = ""
    @Published var sellPrice: String = ""
    @Published var isLoading: Bool = false
    var dismissAction: DismissAction?

    private let wallet: ImmutableXWallet = .shared
    private let core: ImmutableX = .shared

    let asset: AssetDS

    init(asset: AssetDS) {
        self.asset = asset
    }

    func cancelSaleButtonTapped() async {
        defer {
            isLoading = false
        }

        do {
            isLoading = true
            let signer = try await wallet.signer.orThrowIfNil()
            let starkSigner = try await wallet.starkSigner.orThrowIfNil()

            _ = try await core.cancelOrder(
                orderId: "\(asset.orderId.orThrowIfNil())",
                signer: signer,
                starkSigner: starkSigner
            )

            dismissAction?()
        } catch {
            errorAlert = error
        }
    }

    func sellButtonTapped() async {
        defer {
            isLoading = false
        }

        do {
            isLoading = true
            let signer = try await wallet.signer.orThrowIfNil()
            let starkSigner = try await wallet.starkSigner.orThrowIfNil()

            _ = try await core.sell(
                asset: ERC721Asset(tokenAddress: asset.tokenAddress, tokenId: asset.tokenId),
                sellToken: ETHAsset(quantity: sellPrice),
                fees: [],
                signer: signer,
                starkSigner: starkSigner
            )

            dismissAction?()
        } catch {
            errorAlert = error
        }
    }

    func transferButtonTapped() async {
        defer {
            isLoading = false
        }

        do {
            isLoading = true
            let signer = try await wallet.signer.orThrowIfNil()
            let starkSigner = try await wallet.starkSigner.orThrowIfNil()

            _ = try await core.transfer(
                token: ERC721Asset(
                    tokenAddress: asset.tokenAddress,
                    tokenId: asset.tokenId
                ),
                recipientAddress: transferAddress,
                signer: signer,
                starkSigner: starkSigner
            )

            dismissAction?()
        } catch {
            errorAlert = error
        }
    }
}
