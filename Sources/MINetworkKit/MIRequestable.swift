//
//  MINetworkable.swift
//  UtilitiesExample
//
//  Created by Imthath M on 26/07/19.
//  Copyright © 2019 SkyDevz. All rights reserved.
//

import Foundation

public protocol MIRequestable {
  func urlRequest() throws -> URLRequest
}

extension URLRequest: MIRequestable {
  public func urlRequest() throws -> URLRequest { self }
}

extension URL: MIRequestable {
  public func urlRequest() throws -> URLRequest {
    URLRequest(url: self)
  }
}

extension String: MIRequestable {
  public func urlRequest() throws -> URLRequest {
    guard let url = URL(string: self) else {
      ("unable to form url with string " + self).log()
      throw MINetworkError.badURL
    }
    return URLRequest(url: url)
  }
}

public enum MINetworkMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
  case patch = "PATCH"
}

public protocol MIRequest: MIRequestable {
  var urlString: String { get }
  var method: MINetworkMethod { get }
  var params: [String: Any]? { get }
  var headers: [String: String]? { get }
  var body: Data? { get }
  var cachePolicy: URLRequest.CachePolicy { get }
}

public extension MIRequest {
  var params: [String: Any]? { nil }
  var headers: [String: String]? { nil }
  var body: Data? { nil }
  var cachePolicy: URLRequest.CachePolicy? { nil }

  func urlRequest() throws -> URLRequest {
    let fullURL: String = getFullURL(from: params, usingBaseURL: urlString)
    guard let url = URL(string: fullURL) else {
      ("unable to form url with string " + urlString).log()
      throw MINetworkError.badURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
    request.httpBody = body
    if let cachePolicy {
      request.cachePolicy = cachePolicy
    }
    return request
  }

  func getFullURL(from params: [String: Any]?, usingBaseURL baseURL: String) -> String {
    guard let existingParams = params else {
      return baseURL
    }

    let paramString = formattedParamString(from: existingParams)
    if !paramString.isEmpty {
      return baseURL + "?" + paramString
    }

    return baseURL
  }
}

private extension MIRequest {
  func formattedParamString(from params: [String: Any]) -> String {
    var paramString = ""
    for (key, value) in params {
      if let valueString = getValueString(from: value) {
        paramString += getKeyString(from: key, in: paramString)
        paramString += valueString
      }
    }
    return paramString
  }

  func getKeyString(from key: String, in paramString: String) -> String {
    if paramString.isEmpty {
      return key + "="
    }
    return "&" + key + "="
  }

  func getValueString(from value: Any) -> String? {
    if value is [String: Any] && JSONSerialization.isValidJSONObject(value) {
      if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) {
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString.encoded
      }
    }

    return "\(value)".encoded
  }
}
