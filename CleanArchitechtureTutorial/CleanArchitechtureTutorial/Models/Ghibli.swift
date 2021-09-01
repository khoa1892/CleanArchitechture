//
//  Ghibli.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//

import Foundation
import ObjectMapper

class Ghibli: Mappable {
    
    var title: String?
    var id: String?
    var releaseDate: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        id <- map["id"]
        releaseDate <- map["release_date"]
    }
}
