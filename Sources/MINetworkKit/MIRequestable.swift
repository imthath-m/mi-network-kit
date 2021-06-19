//
//  MINetworkable.swift
//  UtilitiesExample
//
//  Created by Imthath M on 26/07/19.
//  Copyright © 2019 Zoho Corp. All rights reserved.
//

import Foundation

public protocol MIRequestable {
    func getURLrequest(from myRequest: MIRequest) -> URLRequest?
    
    func getURLrequest(baseURL: String, using method: MINetworkMethod,
                       headers: [String: String]?, params: [String: Any]?,
                       body: Data?) -> URLRequest?
}

extension MIRequestable {
    
    public func getURLrequest(from myRequest: MIRequest) -> URLRequest? {
        return getURLrequest(baseURL: myRequest.urlString, using: myRequest.method,
                             headers: myRequest.headers, params: myRequest.params,
                             body: myRequest.body)
    }
    
    public func getURLrequest(baseURL: String, using method: MINetworkMethod,
                              headers: [String: String]?, params: [String: Any]?,
                              body: Data?) -> URLRequest? {
        
        guard let url = URL(string: getFullURL(from: params, usingBaseURL: baseURL)) else {
            ("unable to form url with string " + baseURL).log()
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
    
    public func getFullURL(from params: [String: Any]?, usingBaseURL baseURL: String) -> String {
        guard let existingParams = params else { return baseURL }
        
        let paramString = formattedParamString(from: existingParams)
        if !paramString.isEmpty {
            return baseURL + "?" + paramString
        }
        
        return baseURL
    }
    
    private func formattedParamString(from params: [String: Any]) -> String {
        var paramString = ""
        for (key, value) in params {
            if let valueString = getValueString(from: value) {
                paramString += getKeyString(from: key, in: paramString)
                paramString += valueString
            }
        }
        return paramString
    }
    
    private func getKeyString(from key: String, in paramString: String) -> String {
        if paramString.isEmpty {
            return key + "="
        }
        return "&" + key + "="
    }
    
    private func getValueString(from value: Any) -> String? {
        if value is [String: Any] && JSONSerialization.isValidJSONObject(value) {
            if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) {
                let jsonString = String(data: jsonData, encoding: .utf8)!
                return jsonString.encoded
            }
        }
        
        return "\(value)".encoded
    }
}
