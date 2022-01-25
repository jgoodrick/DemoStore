
import Foundation

public final class Store: ObservableObject {
    
    @Published public var offerings: Offerings?
    
    private var inAppStore: InAppStore?
    
    public init() {
        Task {
            self.inAppStore = try await createInAppStore()
        }
    }
    
    public func purchase(_ autoRenewable: AutoRenewable) async {
        guard let inAppStore = inAppStore else {
            assertionFailure()
            return
        }
        guard let product = await inAppStore.state.available.autoRenewables.first(
            where: {$0.id == autoRenewable.id}
        ) else {
            assertionFailure()
            return
        }
        try? await inAppStore.purchase(product)
        let newState = await inAppStore.state
        await handleInAppStoreStateChange(newState)
    }
    
    private func createInAppStore() async throws -> InAppStore {
        try await InAppStore(
            productsPlist: Bundle.init(
                identifier: "com.goodrick.DemoStore"
            )!.url(
                forResource: "Products",
                withExtension: "plist"
            )!,
            onStateChange: handleInAppStoreStateChange
        )
    }
    
    @MainActor
    private func handleInAppStoreStateChange(_ state: InAppStore.State) {
        let newAutoRenewables = state.available.autoRenewables.compactMap({
            $0.asAutoRenewable(entitlements: state.userEntitlements.autoRenewables)
        })
        if var currentOfferings = offerings {
            currentOfferings.autoRenewable = newAutoRenewables
            self.offerings = currentOfferings
        } else {
            self.offerings = .init(autoRenewable: newAutoRenewables)
        }
    }
}

public struct Offerings {
    public var autoRenewable: [AutoRenewable]
}

public struct AutoRenewable: Identifiable {
    
    public let id: String
    public let title: String
    public let description: String
    public let renewalFrequency: RenewalFrequency
    public let purchased: PurchaseState
    
    public init(id: String, title: String, description: String, renewalFrequency: RenewalFrequency, purchased: PurchaseState) {
        self.id = id
        self.title = title
        self.description = description
        self.renewalFrequency = renewalFrequency
        self.purchased = purchased
    }
}

@frozen public enum PurchaseState: Equatable {
    case notPurchased
    case pending(PendingRenewalState)
    case current
}

public struct RenewalFrequency {
    
    public enum Unit {
        case month, year
    }

    public let value: Int
    public let unit: RenewalFrequency.Unit
    
    public init(value: Int, unit: RenewalFrequency.Unit) {
        self.value = value
        self.unit = unit
    }
}

@frozen public enum PendingRenewalState {
    case pendingApproval
    case gracePeriod
}
