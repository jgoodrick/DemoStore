
import StoreKit

struct AvailableProductsFetcher {
    
    let ids: [String]
    
    func availableProducts() async -> Result<Products<Product>, InAppStoreError> {
        do {
            //Request products from the App Store using the identifiers defined in the Products.plist file.
            let storeProducts = try await Product.products(for: ids)
            
            var consumables = [Product]()
            var nonConsumables = [Product]()
            var nonRenewables = [Product]()
            var autoRenewables = [Product]()
            
            //Filter the products into different categories based on their type.
            for product in storeProducts {
                switch product.type {
                case .consumable: consumables.append(product)
                case .nonConsumable: nonConsumables.append(product)
                case .nonRenewable: nonRenewables.append(product)
                case .autoRenewable: autoRenewables.append(product)
                default:
                    assertionFailure("Unhandled product type: \(product.type)")
                    continue
                }
            }
            
            let offerings = Products<Product>.init(
                consumables: consumables,
                nonConsumables: nonConsumables,
                nonRenewables: nonRenewables,
                autoRenewables: autoRenewables
            )
            
            return .success(offerings)
        } catch {
            return .failure(.fetchingProducts)
        }
    }
}

