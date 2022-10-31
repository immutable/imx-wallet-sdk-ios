import SwiftUI

struct AssetView: View {
    @ObservedObject private var viewModel: AssetViewModel
    @Environment(\.dismiss) private var dismissAction

    private var isErrorAlertPresented: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.errorAlert != nil },
            set: { _ in viewModel.errorAlert = nil }
        )
    }

    init(viewModel: AssetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        let asset = viewModel.asset
        ZStack {
            VStack(alignment: .leading) {
                if let imageUrl = asset.imageUrl, let url = URL(string: imageUrl) {
                    image(url)
                }

                Spacer().frame(height: 32)

                Text(asset.name)
                    .bold()
                Text(asset.collectionName)
                    .font(.footnote)

                Spacer().frame(height: 48)

                if let sellPrice = asset.sellPrice {
                    sellingView(price: sellPrice)
                    Spacer().frame(height: 48)
                    transferView
                } else {
                    sellView
                    Spacer().frame(height: 48)
                    transferView
                }

                Spacer()
            }
            .alert(
                "Something went wrong",
                isPresented: isErrorAlertPresented,
                actions: {
                    Button("OK") {}
                }
            )
            .padding(24.0)
            .navigationTitle(viewModel.asset.name)
            .opacity(viewModel.isLoading ? 0.1 : 1.0)

            if viewModel.isLoading {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            viewModel.dismissAction = dismissAction
        }
    }

    private func image(_ url: URL) -> some View {
        HStack {
            Spacer()
            AsyncImage(
                url: url,
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                },
                placeholder: {
                    ProgressView()
                }
            )
            Spacer()
        }
    }

    private func sellingView(price: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Selling for: \(price) ETH")
                    .font(.title2)
            }
            Spacer().frame(height: 12)
            Button("Cancel Sale Order") {
                Task {
                    await viewModel.cancelSaleButtonTapped()
                }
            }
        }
    }

    private var sellView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Sell for")
                    .font(.title2)
                TextField(
                    "ETH amount...",
                    text: Binding<String>(
                        get: { viewModel.sellPrice },
                        set: {
                            viewModel.sellPrice = ($0.isEmpty || Double($0) != nil) ? $0 : viewModel.sellPrice
                        }
                    )
                )
            }

            if !viewModel.sellPrice.isEmpty {
                Button("Sell Asset") {
                    Task {
                        await viewModel.sellButtonTapped()
                    }
                }
            }
        }
    }

    private var transferView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Transfer to")
                    .font(.title2)
                TextField(
                    "ETH address...",
                    text: Binding<String>(
                        get: { viewModel.transferAddress },
                        set: { viewModel.transferAddress = $0 }
                    )
                )
            }

            if !viewModel.transferAddress.isEmpty {
                Button("Transfer Asset") {
                    Task {
                        await viewModel.transferButtonTapped()
                    }
                }
            }
        }
    }
}

struct AssetView_Previews: PreviewProvider {
    static var previews: some View {
        AssetView(
            viewModel: AssetViewModel(
                asset: .init(
                    name: "Basic Squid",
                    collectionName: "BANNER",
                    imageUrl: "https://cdn.blocklords.com/nfts/banner/054_C.gif",
                    sellPrice: nil,
                    tokenId: "334",
                    tokenAddress: "0xb2d73b6a1da13882c15ca7e248051e38f0abd1e6",
                    orderId: nil
                )
            )
        )
    }
}
