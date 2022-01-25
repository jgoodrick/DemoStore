
import StoreKit

final class TransactionsListener {
    
    private var onEvent: () async -> Void
    private var updateListenerTask: Task<Void, Error>?
    
    init(onEvent: @escaping () async -> Void) {
        self.onEvent = onEvent
        self.updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            guard let self = self else { return }
            //transactions which didn't come from a direct call to `purchase()`:
            for await result in Transaction.updates {
                do {
                    guard let transaction = result.verified else {
                        throw DemoStoreError.failedVerification
                    }
                    
                    // notify the parent that it's time to update the current entitlements
                    await self.onEvent()
                    
                    await transaction.wrapped.finish()
                } catch {
                    //StoreKit has a receipt it can read but it failed verification.
                    print("Transaction failed verification")
                }
            }
        }
    }
}
