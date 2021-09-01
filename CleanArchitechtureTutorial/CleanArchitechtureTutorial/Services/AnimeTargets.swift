//
//  AnimeTargets.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//

import Foundation
import ObjectMapper
import Alamofire

enum GhibliConstant {
    
    struct GetListParams {
        let limit:Int?
    }
}

public enum AnimeTargets {
    struct FetchGhibliListTarget: Requestable {
        
        typealias Output = [Ghibli]?
        
        let ghibliParams: GhibliConstant.GetListParams
        
        var params: Parameters {
            let dict = ["limit": "\(ghibliParams.limit ?? 0)"]
            return dict
        }
        
        var endpoint:String {
            return "/films"
        }
        
        func decode(data: Any) -> Output {
            return Mapper<Ghibli>().mapArray(JSONArray: data as? [[String: Any]] ?? [[:]])
        }
    }
}
