import SwiftUI

struct SellView: View {
    @ObservedObject private var viewModel: SellViewModel

    private var isErrorAlertPresented: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.errorAlert != nil },
            set: { _ in viewModel.errorAlert = nil }
        )
    }

    init(viewModel: SellViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        stateView
            .alert(
                "Something went wrong",
                isPresented: isErrorAlertPresented,
                actions: {
                    Button("OK") {}
                }
            )
            .onAppear {
                Task {
                    await viewModel.onAppear()
                }
            }
            .navigationTitle("My Assets")
    }

    @ViewBuilder private var stateView: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading...")
        case .error:
            VStack {
                Text("Ops something went wrong...")
                Spacer().frame(height: 48)
                Button("Retry", action: {
                    Task {
                        await viewModel.retryButtonTapped()
                    }
                })
            }
        case let .loaded(assets: assets, balance: balance):
            VStack {
                Text("ETH balance: \(balance)")
                Spacer().frame(height: 48)
                List {
                    Section("My Assets") {
                        ForEach(assets) { asset in
                            NavigationLink(
                                destination: AssetView(viewModel: .init(asset: asset))
                            ) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(asset.name)
                                            .bold()
                                        Text(asset.collectionName)
                                            .font(.footnote)
                                    }
                                    Spacer()

                                    if let price = asset.sellPrice {
                                        VStack(alignment: .leading) {
                                            Text("Selling for")
                                                .font(.caption)
                                            Text("\(price) ETH")
                                                .font(.caption)
                                        }
                                    }
                                }
                                .padding(8.0)
                            }
                        }
                    }
                }
                .refreshable {
                    Task {
                        await viewModel.pullToRefreshTriggered()
                    }
                }
            }
        }
    }
}

struct SellView_Previews: PreviewProvider {
    static var previews: some View {
        SellView(viewModel: SellViewModel())
    }
}
