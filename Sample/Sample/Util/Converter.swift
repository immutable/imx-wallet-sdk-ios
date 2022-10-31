import Foundation

struct Converter {
    static func convertToEther(_ value: String?) -> String? {
        guard let value, !value.isEmpty, let valueDec = Decimal(string: value) else { return nil }

        // Convert wei to ether
        let ten18 = pow(10 as Decimal, 18)
        let ether = valueDec / ten18
        return "\(max(ether, 0))"
    }

    static func formatPrice(quantity: String?, decimal: Int?) -> String? {
        guard let quantity,
              let decimalQuantity = Decimal(string: quantity),
              let decimal else { return nil }

        let dec = Decimal(pow(Double(10), Double(decimal)))
        return "\(decimalQuantity / dec)"
    }
}
