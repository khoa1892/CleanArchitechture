//
//  Requestable.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//
import Foundation
import RxSwift
import ObjectMapper
import Alamofire

public enum CTApiClientRequestType {
    case upload
    case http
}

public protocol Requestable: URLRequestConvertible {
    associatedtype Output
    
    var basePath: String { get }
    
    var endpoint: String { get }
    
    var httpMethod: HTTPMethod { get }
    
    var params: Parameters { get }
    
    var defaultHeaders: HTTPHeaders { get }
    
    var additionalHeaders: HTTPHeaders { get }
    
    var parameterEncoding: ParameterEncoding { get }
    
    var statusCode: Range<Int> { get }
    
    var contentType: [String] { get }
    
    var customData: Data { get }
    
    var requestType: CTApiClientRequestType { get }
    
    var queue: DispatchQueue { get }
    
    func execute() -> Observable<Output>
    
    func decode(data: Any) -> Output
}

public extension Requestable {
    var basePath: String {
        return "https://ghibliapi.herokuapp.com"
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var params: Parameters {
        return [:]
    }
    
    var defaultHeaders: HTTPHeaders {
        return ["Accept": "application/json"]
    }
    
    var additionalHeaders: HTTPHeaders {
        return [:]
    }

    var urlPath: String {
        return basePath + endpoint
    }
    
    var customData: Data {
        return Data()
    }
    
    var requestType: CTApiClientRequestType {
        return .http
    }
    
    var url: URL {
        return URL(string: urlPath)!
    }
    
    var parameterEncoding: ParameterEncoding {
        switch httpMethod {
        case .post, .put, .delete:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    var statusCode: Range<Int> {
        return 200..<300
    }
    
    var contentType: [String] {
        return ["application/json", "text/plain"]
    }
    
    var queue: DispatchQueue {
        return DispatchQueue.global(qos: .default)
    }
    
    @discardableResult
    func execute() -> Observable<Output> {
        return asObservable()
    }
    
    fileprivate func buildURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.timeoutInterval = 10
        urlRequest = try parameterEncoding.encode(urlRequest, with: params)
        var headers = defaultHeaders
        for (key, val) in additionalHeaders {
            headers[key] = val
        }
        
        for (key, val) in headers {
            urlRequest.addValue(val, forHTTPHeaderField: key)
        }
        
        return urlRequest
    }
    
    func connectWithRequest(
        _ urlRequest: URLRequest,
        complete: @escaping (DataResponse<Any>) -> Void
    ) -> DataRequest? {
        
        let sessionManager = Alamofire.SessionManager.default
        
        switch requestType {
        case .http:
            return httpRequest(urlRequest: urlRequest,
                               sessionManager: sessionManager,
                               complete: complete)
        case .upload:
            upload(urlRequest: urlRequest,
                   sessionManager: sessionManager,
                   complete: complete)
            return nil
        }
    }
    
    private func upload(
        urlRequest: URLRequest,
        sessionManager: SessionManager,
        complete: @escaping (DataResponse<Any>) -> Void
    ) {
        sessionManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(customData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                for (key, val) in params {
                    if let utf8String = (val as? String)?.data(using: .utf8) {
                        multipartFormData.append(utf8String, withName: key)
                    }
                }
            },
            usingThreshold: UInt64.init(),
            to: url,
            method: httpMethod,
            headers: urlRequest.allHTTPHeaderFields) { result in
            switch result {
            case .success(let request, _, _):
                self.requestJSON(request: request, complete: complete)
            case .failure(let error):
                let failResponse = DataResponse(request: urlRequest,
                                                response: nil,
                                                data: nil,
                                                result: Result<Any>.failure(error))
                complete(failResponse)
            }
        }
    }
    
    private func httpRequest(
        urlRequest: URLRequest,
        sessionManager: SessionManager,
        complete: @escaping (DataResponse<Any>) -> Void
        ) -> DataRequest {
        let request = sessionManager.request(urlRequest)

        debugPrint(request)

        requestJSON(request: request, complete: complete)
    
        return request
    }
    
    private func requestJSON(
        request: DataRequest,
        complete: @escaping (DataResponse<Any>) -> Void
    ) {
        request.validate(statusCode: statusCode)
        request.validate(contentType: contentType)
    
        request
            .responseJSON(completionHandler: { response in
                complete(response)
            })
    }
    
    private func asObservable() -> Observable<Output> {
        return Observable.create { observer in
            guard let urlRequest = try? self.asURLRequest() else {
                let errorResponse = LoadingError.notFound(
                    "Not Found"
                )
                observer.onError(errorResponse)
                return Disposables.create()
            }
            
            let connection = self.connectWithRequest(urlRequest, complete: { response in
                switch response.result {
                case let .success(data):
                    if data is [Any] {
                        observer.onNext(self.decode(data: data))
                        observer.onCompleted()
                        return
                    }
                    let responseData = Mapper<ResponseEntity<EmptyEntity>>().map(JSONObject: data)
                    if responseData?.isSuccess ?? false {
                        observer.onNext(self.decode(data: data))
                        observer.onCompleted()
                    } else {
                        observer.onError(self.error(ofReponse: response,
                                                    statusCode: nil,
                                                    error: nil))
                    }
                    
                case let .failure(error):
                    var httpStatusCode: HTTPStatusCode?
                    if let statusCode = response.response?.statusCode {
                        httpStatusCode = HTTPStatusCode(rawValue: statusCode)
                    }
                    let errorResponse = self.error(
                        ofReponse: response,
                        statusCode: httpStatusCode,
                        error: error)
                    
                    observer.onError(errorResponse)
                }
            })
            
            return Disposables.create {
                connection?.cancel()
            }
        }
    }
}

// MARK: - Conform URLConvertible from Alamofire
public extension Requestable {
    
    func asURLRequest() throws -> URLRequest {
        return try buildURLRequest()
    }
    
}

public extension Requestable {
    func error(ofReponse response: (Alamofire.DataResponse<Any>)?, statusCode: HTTPStatusCode?, error: Error?) -> LoadingError {
        
        let httpStatusCode = HTTPStatusCode(rawValue: response?.response?.statusCode ?? 0) ?? .notFound
        
        if let data = response?.data,
           let jsonError = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            var message = "error"
            if let messageResponse = jsonError["message_error"] as? String {
                message = messageResponse
            }
            
            if let messageResponse = jsonError["error"] as? String {
                message = messageResponse
            }
            
            if let messageResponse = jsonError["message"] as? String {
                message = messageResponse
            }
            
            return .otherError(message, dataRes: jsonError)
        }
        
        if let err = error as? URLError,
           (err.code == .notConnectedToInternet
                || err.code == .networkConnectionLost
                || err.code == .cannotLoadFromNetwork) {
            return .noInternet
        }
        
        if httpStatusCode == .notFound {
            return .notFound("Not Found")
        }
        
        return .otherError(
            "Other Error",
            dataRes: nil
        )
    }
}
