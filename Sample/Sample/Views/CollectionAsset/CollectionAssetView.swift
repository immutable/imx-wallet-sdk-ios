import SwiftUI

struct CollectionAssetView: View {
    @ObservedObject private var viewModel: CollectionAssetViewModel
    @Environment(\.dismiss) private var dismissAction

    private var isAlertPresented: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.alert != nil },
            set: { _ in viewModel.alert = nil }
        )
    }

    init(viewModel: CollectionAssetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        stateView
            .alert(
                viewModel.alert?.title ?? "",
                isPresented: isAlertPresented,
                actions: {
                    Button("OK") {
                        guard case .success = viewModel.alert else { return }
                        dismissAction()
                    }
                }
            )
            .onAppear {
                Task {
                    await viewModel.onAppear()
                }
            }
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
        case let .loaded(assets: assets):
            ZStack {
                Spacer().frame(height: 48)
                List(assets) { asset in
                    HStack(spacing: 16) {
                        if let imageUrl = asset.imageUrl, let url = URL(string: imageUrl) {
                            image(url)
                        }
                        VStack(alignment: .leading) {
                            Text(asset.name)
                                .bold()

                            sellingView(asset: asset)
                        }
                        Spacer()
                    }
                    .padding(16)
                }
                .navigationTitle(viewModel.collection.name)
                .opacity(viewModel.isBuying ? 0.1 : 1.0)
                .refreshable {
                    Task {
                        await viewModel.pullToRefreshTriggered()
                    }
                }

                if viewModel.isBuying {
                    ProgressView("Loading...")
                }
            }
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
                        .frame(maxHeight: 150)
                        .cornerRadius(8)
                },
                placeholder: {
                    ProgressView()
                }
            )
            Spacer()
        }
    }

    private func sellingView(asset: CollectionAssetDS) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Selling for: \(asset.price) ETH")
                    .font(.caption)
            }
            Spacer().frame(height: 12)
            Button("Buy") {
                Task {
                    await viewModel.buyButtonTapped(asset)
                }
            }
        }
    }
}

struct CollectionAssetView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionAssetView(
            viewModel: CollectionAssetViewModel(
                collection: .init(
                    address: "0xabc",
                    collectionImageUrl: nil,
                    description: "Some description",
                    iconUrl: nil,
                    metadataApiUrl: nil,
                    name: "Some name",
                    projectId: 1,
                    projectOwnerAddress: "0xowner"
                )
            )
        )
    }
}
