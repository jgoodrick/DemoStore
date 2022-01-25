
import StoreKit

public struct Offerings<T> {
    var consumables: [T] = []
    var nonConsumables: [T] = []
    var nonRenewables: [T] = []
    var autoRenewables: [T] = []
}

extension Offerings {
    mutating func append(_ value: T, to productType: Product.ProductType) {
        switch productType {
        case .consumable: self.consumables.append(value)
        case .nonConsumable: self.nonConsumables.append(value)
        case .nonRenewable: self.nonRenewables.append(value)
        case .autoRenewable: self.autoRenewables.append(value)
        default:
            assertionFailure()
            return
        }
    }
}
