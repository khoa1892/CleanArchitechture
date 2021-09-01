//
//  LoadingError.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//

import Foundation

public enum LoadingError: Error {
    case noInternet
    case noResponse
    case notFound(_ message: String?)
    case otherError(_ message: String?, dataRes: [String: Any]? = nil)
}

extension LoadingError: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .noInternet:
            return "No Internet"
        case .noResponse:
            return "No Response"
        case let .notFound(message):
            if let m = message {
                return m
            }
        case let .otherError(message, _):
            if let m = message {
                return m
            }
        }
        
        return "Error"
    }
}

extension LoadingError: Equatable {
    
    public static func ==(lhs: LoadingError, rhs: LoadingError) -> Bool {
        
        switch (lhs, rhs) {
        case (.noInternet, .noInternet):
            return true
        case (.noResponse, .noResponse):
            return true
        case (.notFound, .notFound):
            return true
        case (.otherError(let message1, _), .otherError(let message2, _)):
            return message1 == message2
        default:
            return false
        }
    }
}
