import Foundation
import ImmutableXWalletSDK

enum AlertType: Equatable {
    case none
    case pendingSignature
    case pendingConnection
}

@MainActor
final class StatusAlertViewModel: ObservableObject {
    private static let callbackId = "Alert"

    @Published var alert: AlertType = .none

    private let wallet: ImmutableXWallet = .shared

    init() {
        // ImmutableXWallet is an actor and requires an async context
        Task {
            await wallet.setStatusCallbackForId(StatusAlertViewModel.callbackId) { [weak self] status in
                await self?.updateStatus(status)
            }
        }
    }

    private func updateStatus(_ status: ImmutableXWalletStatus) async {
        switch status {
        case .connecting, .connected, .disconnecting, .disconnected:
            break
        case .pendingConnection:
            alert = .pendingConnection
        case .pendingSignature:
            alert = .pendingSignature
        }
    }
}
