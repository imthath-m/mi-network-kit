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
    var method: MINetworkMethod { get }
    var params: [String: Any]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

public enum MINetworkMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
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
