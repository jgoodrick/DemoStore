
import Foundation

final class ProductIDsReader {
    
    let ids: [String]
    
    init(productsPlist: URL) throws {
        guard let plist = FileManager.default.contents(atPath: productsPlist.path) else {
            throw DemoStoreError.missingProductsPlist
        }
        
        guard let result = try? PropertyListSerialization.propertyList(from: plist, format: nil) else {
            throw DemoStoreError.invalidProductsPlist
        }
        
        guard let ids = result as? [String] else {
            throw DemoStoreError.invalidProductsPlist
        }
        
        guard !ids.isEmpty else {
            throw DemoStoreError.emptyProductsPlist
        }
        
        self.ids = ids
    }
}

