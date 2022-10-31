import Foundation

/**
 * ERC721
 */
struct OrderSellResponse: Codable, Equatable, Identifiable {
    let status: String
    let orderId: Int
    let buyQuantity: String
    let buyDecimals: Int
    let user: String

    var id: Int {
        orderId
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case status
        case orderId = "order_id"
        case buyQuantity = "buy_quantity"
        case buyDecimals = "buy_decimals"
        case user
    }
}
