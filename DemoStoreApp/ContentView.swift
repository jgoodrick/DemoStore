
import SwiftUI
import DemoStore

struct ContentView: View {
    
    let subscriptions: [AutoRenewable]
    
    var body: some View {
        if subscriptions.isEmpty {
            Text("No subscriptions available")
        } else {
            List(subscriptions) { subscription in
                Button(subscription.title) {
                    print("hit the \(subscription.id) button")
                }
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
            ]
        )
    }
}
