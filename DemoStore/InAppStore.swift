
import StoreKit

actor InAppStore {
        
    struct State {
        var available: Products<Product> = .init()
        var userEntitlements: Products<String> = .init()
        var pendingPurchases: Products<String> = .init()
    }
    
    var state: State = .init() {
        didSet {
            Task { await onStateChange(state) }
        }
    }
    
    private let userEntitlementsFetcher: UserEntitlementsFetcher
    private let onStateChange: (State) async -> Void
    
    private var transactionsListener: TransactionsListener?
    
    init(productsPlist: URL, onStateChange: @escaping (State) async -> Void) async throws {
        
        self.onStateChange = onStateChange
        self.userEntitlementsFetcher = UserEntitlementsFetcher()

        self.transactionsListener = TransactionsListener(
            onEvent: { [weak self] in await self?.updateUsersCurrentEntitlements() }
        )

        let assetReader = try ProductIDsReader(
            productsPlist: productsPlist
        )
        
        let availableProductsFetcher = AvailableProductsFetcher(ids: assetReader.ids)
        
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
    
    private func updateUsersCurrentEntitlements() async {
        self.state.userEntitlements = await userEntitlementsFetcher.current().wrapped
    }
    
    public func purchase(_ product: Product) async throws {
        switch try await product.purchase() {
        case .success:
            await updateUsersCurrentEntitlements()
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
