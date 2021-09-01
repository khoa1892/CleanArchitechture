
import UIKit
import ObjectMapper

public struct EmptyEntity: Mappable {
    public var tracking: Bool = false
    
    public init?(map: Map) {
    }
    
    mutating public func mapping(map: Map) {
        tracking <- map["tracking"]
    }
    
    public var isSuccess: Bool {
        return tracking
    }
}
