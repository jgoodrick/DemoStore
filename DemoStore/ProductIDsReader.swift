
import Foundation

final class ProductIDsReader {
    
    let ids: [String]
    
    init(productsPlist: URL) throws {
        guard let plist = FileManager.default.contents(atPath: productsPlist.path) else {
            throw InAppStoreError.missingProductsPlist
        }
        
        guard let result = try? PropertyListSerialization.propertyList(from: plist, format: nil) else {
            throw InAppStoreError.invalidProductsPlist
        }
        
        guard let ids = result as? [String] else {
            throw InAppStoreError.invalidProductsPlist
        }
        
        guard !ids.isEmpty else {
            throw InAppStoreError.emptyProductsPlist
        }
        
        self.ids = ids
    }
}

