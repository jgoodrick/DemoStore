
import SwiftUI
import DemoStore

struct ContentView: View {
    
    let subscriptions: [AutoRenewable]
    let purchaser: Purchaser
    
    var body: some View {
        if subscriptions.isEmpty {
            Text("No subscriptions available")
        } else {
            List(subscriptions) { subscription in
                Button(subscription.title) {
                    Task {
                        await purchaser.purchase(subscription)
                    }
                }.disabled(subscription.purchased == PurchaseState.current)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            subscriptions: [
                .init(
                    id: "1",
                    title: "First",
                    description: "First subscription",
                    renewalFrequency: .init(
                        value: 1,
                        unit: .month
                    ),
                    purchased: .notPurchased
                )
            ],
            purchaser: MockPurchaser()
        )
    }
}

struct MockPurchaser: Purchaser {
    func purchase(_ autoRenewable: AutoRenewable) async {}
}
