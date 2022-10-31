import Foundation

/// A data structure representing an Asset from the UI's perspective
struct AssetDS: Identifiable {
    let name: String
    let collectionName: String
    let imageUrl: String?
    let sellPrice: String?
    let tokenId: String
    let tokenAddress: String
    let orderId: Int?

    var id: String {
        tokenId
    }
}
