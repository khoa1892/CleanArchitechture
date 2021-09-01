
import Foundation
import ObjectMapper

public struct ResponseEntity<T: Mappable> {
    public var data: T?
    public var message: String?
    
    public init?(map: Map) {
        
    }
}

extension ResponseEntity: Mappable {
    
    public mutating func mapping(map: Map) {
        data <- map["result"]
        message <- map["message"]
    }
    
    public var isSuccess: Bool {
        if data == nil { return true }
        return data != nil
    }
}
