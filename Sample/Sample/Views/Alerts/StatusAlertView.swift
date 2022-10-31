import Foundation
import SwiftUI

struct StatusAlertView: View {
    @ObservedObject private var viewModel: StatusAlertViewModel

    init(viewModel: StatusAlertViewModel) {
        self.viewModel = viewModel
    }

    private var isAlertPresented: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.alert != .none },
            set: { _ in viewModel.alert = .none }
        )
    }

    private var alertTitle: String {
        switch viewModel.alert {
        case .none:
            return ""
        case .pendingConnection:
            return "Pending Connection"
        case .pendingSignature:
            return "Pending Signature"
        }
    }

    private var alertMessage: String {
        switch viewModel.alert {
        case .none:
            return ""
        case .pendingConnection:
            return "Please accept the connection request in your wallet app..."
        case .pendingSignature:
            return "Please sign the request in your wallet app..."
        }
    }

    var body: some View {
        Text("")
            .alert(
                alertTitle,
                isPresented: isAlertPresented,
                actions: {
                    Button("OK") {}
                },
                message: {
                    Text(alertMessage)
                }
            )
    }
}
