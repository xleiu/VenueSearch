import Foundation

enum VenueError: Error {
    case None
    case requestFailed
    case locationAuthenticationFailed
    case locationRequestPending
    case locationError
    case respondFailed
    case jsonParseFailure
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "venue request failed"
        case .locationAuthenticationFailed: return "location authentication failed"
        case .locationRequestPending: return "location request pending"
        case .locationError: return "location query failed"
        case .respondFailed: return "venue respond failed"
        case .jsonParseFailure: return "json data invalid"
        case .invalidData: return "venue data invalid"
        case .None: return ""
        }
    }
}

enum Result<T, E> where E: Error {
    case success(T)
    case failure(E)
}
