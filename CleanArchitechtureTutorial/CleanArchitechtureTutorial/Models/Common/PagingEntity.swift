
import Foundation
import ObjectMapper

public struct PagingEntity<T: Mappable> {
    public var page: Int?
    public var items: [T]?
    
    public init?(map: Map) {
        
    }
}

extension PagingEntity: Mappable {
    
    public mutating func mapping(map: Map) {
        page <- map["page"]
        items <- map["result"]
    }
}
