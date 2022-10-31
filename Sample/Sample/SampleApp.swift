import ImmutableXCore
import SwiftUI

@main
struct SampleApp: App {
    init() {
        ImmutableX.initialize(base: .sandbox, logLevel: .calls(including: [.requestBody]))
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: .init())
        }
    }
}
