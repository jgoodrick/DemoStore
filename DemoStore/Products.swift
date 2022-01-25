
import StoreKit

public struct Products<T> {
    var consumables: [T] = []
    var nonConsumables: [T] = []
    var nonRenewables: [T] = []
    var autoRenewables: [T] = []
}

extension Products {
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

extension Product {
    func asAutoRenewable(entitlements: [String]) -> AutoRenewable? {

        let purchaseState: PurchaseState = entitlements.contains(id) ? .current : .notPurchased
        
        guard let frequency = subscription?.renewalFrequency else {
            assertionFailure()
            return nil
        }
        
        return .init(
            id: id,
            title: displayName,
            description: description,
            renewalFrequency: frequency,
            purchased: purchaseState
        )
    }
}

extension Product.SubscriptionInfo {
    var renewalFrequency: RenewalFrequency? {
        switch subscriptionPeriod.unit {
        case .month: return .init(value: subscriptionPeriod.value, unit: .month)
        case .year: return .init(value: subscriptionPeriod.value, unit: .year)
        default:
            assertionFailure()
            return nil
        }
    }
}
