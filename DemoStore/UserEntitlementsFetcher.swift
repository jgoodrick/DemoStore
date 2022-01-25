
import StoreKit

struct UserEntitlementsFetcher {
    func current() async -> Verified<Offerings<String>> {
        
        var consumables = [Transaction]()
        var nonConsumables = [Transaction]()
        var nonRenewables = [Transaction]()
        var autoRenewables = [Transaction]()
        
        for await verificationResult in Transaction.currentEntitlements {
            guard let verifiedTransaction = verificationResult.verified else {
                continue
            }
            
            switch verifiedTransaction.wrapped.productType {
            case .consumable: consumables.append(verifiedTransaction.wrapped)
            case .nonConsumable: nonConsumables.append(verifiedTransaction.wrapped)
            case .nonRenewable: nonRenewables.append(verifiedTransaction.wrapped)
            case .autoRenewable: autoRenewables.append(verifiedTransaction.wrapped)
            default:
                assertionFailure("Unhandled product type: \(verifiedTransaction.wrapped.productType)")
                continue
            }
        }
        
        return Verified<Offerings<String>>.init(
            wrapped: .init(
                consumables: consumables.map({$0.productID}),
                nonConsumables: nonConsumables.map({$0.productID}),
                nonRenewables: nonRenewables.map({$0.productID}),
                autoRenewables: autoRenewables.map({$0.productID})
            )
        )
    }
}

