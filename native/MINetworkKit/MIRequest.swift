//
//  ZDRequest.swift
//  ZDPortalNetworkKit
//
//  Created by Imthath M on 16/08/19.
//  Copyright © 2019 Zoho Corp. All rights reserved.
//

import Foundation

public protocol MIRequest {
    var urlString: String { get }
    var method: NetworkMethod { get }
    var params: [String: Any]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

internal extension MIRequest {

    func dictionary(from tuples: [(String, Any?)]) -> [String: Any] {
        var dict = [String: Any]()

        for (key, value) in tuples {
            if let existingValue = value {
                dict.updateValue(existingValue, forKey: key)
            }
        }

        return dict
    }
}

//internal class ZDResponse<DataType: Codable>: Codable {
//
//    var data: [DataType] = []
//
//    internal init() { }
//    
//}
//
//internal class ZDResponseData {
//    
//    static func handle<AnyDecodable: Codable>(_ result: Result<ZDResponse<AnyDecodable>, MINetworkError>, as type: [AnyDecodable],
//                                              onCompletion handler: @escaping (Result<[AnyDecodable], MINetworkError>) -> Void) {
//        switch result {
//        case .success(let response):
//            handler(.success(response.data))
//        case .failure(let error):
//            handler(.failure(error))
//        }
//    }
//}
