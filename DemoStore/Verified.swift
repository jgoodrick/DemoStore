
import StoreKit

struct Verified<T> {
    let wrapped: T
}

extension VerificationResult where SignedType == Transaction {
    var verified: Verified<SignedType>? {
        switch self {
        case .unverified:
            //StoreKit has parsed the JWS but failed verification.
            return nil
        case let .verified(safe):
            return Verified(wrapped: safe)
        }
    }
}
