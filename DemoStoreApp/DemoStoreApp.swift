
import SwiftUI
import DemoStore

@main
struct DemoStoreApp: App {
    
    @StateObject var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView(subscriptions: store.offerings?.autoRenewable ?? [])
        }
    }
}
