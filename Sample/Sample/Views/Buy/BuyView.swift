import SwiftUI

struct BuyView: View {
    @ObservedObject private var viewModel: BuyViewModel

    private var isErrorAlertPresented: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.errorAlert != nil },
            set: { _ in viewModel.errorAlert = nil }
        )
    }

    init(viewModel: BuyViewModel) {
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
            .navigationTitle("Collections")
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
        case let .loaded(collections: collections):
            List {
                ForEach(collections) { collection in
                    NavigationLink(
                        destination: CollectionAssetView(viewModel: .init(collection: collection))
                    ) {
                        Text(collection.name)
                            .bold()
                            .padding(8.0)
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

struct BuyView_Previews: PreviewProvider {
    static var previews: some View {
        BuyView(viewModel: BuyViewModel())
    }
}
