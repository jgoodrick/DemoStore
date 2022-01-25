
public enum InAppStoreError: Error {
    case missingProductsPlist
    case invalidProductsPlist
    case emptyProductsPlist
    case fetchingProducts
    case failedVerification
}
