
import XCTest
@testable import DemoStore
import StoreKitTest

class DemoStoreTests: XCTestCase {
    
    let productsPlist = Bundle.init(identifier: "com.goodrick.DemoStoreTests")!.url(forResource: "TestProducts", withExtension: "plist")!

    func test_() async throws {
        let store = try await InAppStore(
            productsPlist: productsPlist,
            onStateChange: { _ in }
        )
        let session = try SKTestSession(configurationFileNamed: "Configuration")
        session.disableDialogs
        session.clearTransactions()
        let state = await store.state
        XCTAssertEqual(state.available.autoRenewables.count, 5)
        
    }

}
