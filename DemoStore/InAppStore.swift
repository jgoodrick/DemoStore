
import StoreKit

actor InAppStore {
        
    struct State {
        var available: Products<Product> = .init()
        var userEntitlements: Products<String> = .init()
        var pendingPurchases: Products<String> = .init()
    }
    
    var state: State = .init()
    
    private let availableProductsFetcher: AvailableProductsFetcher
    private let userEntitlementsFetcher: UserEntitlementsFetcher
    private let onStateChange: @MainActor (State) async -> Void
    
    private var transactionsListener: TransactionsListener?
    
    init(productsPlist: URL, onStateChange: @escaping (State) async -> Void) async throws {
        
        self.onStateChange = onStateChange
        self.userEntitlementsFetcher = UserEntitlementsFetcher()

        let assetReader = try ProductIDsReader(
            productsPlist: productsPlist
        )
        
        self.availableProductsFetcher = AvailableProductsFetcher(ids: assetReader.ids)
        
        self.transactionsListener = TransactionsListener(
            onEvent: { [weak self] in
                try? await self?.updateState()
            }
        )

        do {
            try await updateState()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
        
    private func updateState() async throws {
        switch await availableProductsFetcher.availableProducts() {
        case let .success(products):
            
            let currentEntitlements = await userEntitlementsFetcher.current().wrapped
            
            let initialState = State.init(
                available: products,
                userEntitlements: currentEntitlements,
                pendingPurchases: .init()
            )
            
            self.state = initialState
            
            await onStateChange(initialState)
            
        case let .failure(storeError):
            throw storeError
        }
    }
        
    public func purchase(_ product: Product) async throws {
        switch try await product.purchase() {
        case let .success(verificationResult):
            guard let verifiedID = verificationResult.verified?.wrapped.productID else {
                assertionFailure()
                return
            }
            guard verifiedID == product.id else {
                assertionFailure()
                return
            }
            state.userEntitlements.autoRenewables.append(verifiedID)
        case .userCancelled:
            return
        case .pending:
            state.userEntitlements.append(product.id, to: product.type)
        @unknown default:
            assertionFailure()
            return
        }
    }
}
