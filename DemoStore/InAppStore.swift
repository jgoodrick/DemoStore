
import Foundation
import StoreKit

final class InAppStore: ObservableObject {
    
    @Published public var available: Offerings<Product> = .init()
    @Published public var userEntitlements: Offerings<String> = .init()
    @Published public var pendingPurchases: Offerings<String> = .init()
    
    private let availableProductsFetcher: AvailableProductsFetcher
    private let userEntitlementsFetcher: UserEntitlementsFetcher
    
    private var transactionsListener: TransactionsListener?
    
    init(productsPlist: URL) throws {
        
        let assetReader = try ProductIDsReader(
            productsPlist: productsPlist
        )
        
        self.availableProductsFetcher = AvailableProductsFetcher(ids: assetReader.ids)
        self.userEntitlementsFetcher = UserEntitlementsFetcher()
        
        self.transactionsListener = TransactionsListener(
            onEvent: { [weak self] in await self?.updateUsersCurrentEntitlements() }
        )
        
        Task { [weak self] in
            guard let self = self else { return }
            let result = await self.availableProductsFetcher.availableProducts()
            await self.handleAvailableProductsFetcher(result)
        }
    }
    
    @MainActor
    private func handleAvailableProductsFetcher(_ result: Result<Offerings<Product>, DemoStoreError>) {
        switch result {
        case let .success(products):
            self.available = products
            updateUsersCurrentEntitlements()
        case let .failure(storeError):
            assertionFailure(storeError.localizedDescription)
            return
        }
    }
    
    @MainActor
    private func handleVerifiedTransactionEvent(_ transaction: Verified<Transaction>) {
        updateUsersCurrentEntitlements()
    }
    
    @MainActor
    private func updateUsersCurrentEntitlements() {
        Task {
            self.userEntitlements = await userEntitlementsFetcher.current().wrapped
        }
    }
    
    @MainActor
    public func purchase(_ product: Product) async throws {
        switch try await product.purchase() {
        case .success:
            updateUsersCurrentEntitlements()
        case .userCancelled:
            return
        case .pending:
            userEntitlements.append(product.id, to: product.type)
        @unknown default:
            assertionFailure()
            return
        }
    }
}
