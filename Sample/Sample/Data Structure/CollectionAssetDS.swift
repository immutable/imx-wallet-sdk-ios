import Foundation
import SwiftUI

/// A data structure representing a Collection's Asset from the UI's perspective
struct CollectionAssetDS: Equatable, Identifiable {
    let price: String
    let name: String
    let imageUrl: String?
    let orderId: Int

    var id: Int {
        orderId
    }
}
