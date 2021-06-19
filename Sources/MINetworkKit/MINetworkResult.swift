//
//  NetworkResult.swift
//  UtilitiesExample
//
//  Created by Imthath M on 29/07/19.
//  Copyright © 2019 Zoho Corp. All rights reserved.
//

import Foundation

public enum MINetworkError: Error {
    /// when URL initialization from String fails
    case badURL

    /// when server fails to parse URLRequest
    case badRequest
    
    case noInternet
    case timedOut
    case notFound
    case accessDenied
    case badResponse
    case noData
    case invalidStatusCode(Int)
    case decodingFailed(Data, Error)
    case unknownError(String)
}

extension MINetworkError {
    
    internal static func parse(error: NSError) -> MINetworkError {
        guard error.domain == NSURLErrorDomain else {
            return .unknownError("\(error)")
        }

        if error.code == NSURLErrorNotConnectedToInternet ||
            error.code == NSURLErrorNetworkConnectionLost {
            return .noInternet
        }

        if error.code == NSURLErrorBadURL ||
            error.code == NSURLErrorUnsupportedURL {
            return .badRequest
        }

        if error.code == NSURLErrorTimedOut { return .timedOut }

        if error.code == NSURLErrorCannotFindHost ||
            error.code == NSURLErrorCannotConnectToHost ||
            error.code == NSURLErrorDNSLookupFailed ||
            error.code == NSURLErrorResourceUnavailable {
            return .notFound
        }

        if error.code == NSURLErrorUserCancelledAuthentication ||
            error.code == NSURLErrorUserAuthenticationRequired {
            return .accessDenied
        }

        if error.code == NSURLErrorBadServerResponse ||
            error.code == NSURLErrorCannotLoadFromNetwork ||
            error.code == NSURLErrorCannotParseResponse {
            return .badResponse
        }

        if error.code == NSURLErrorCannotDecodeRawData ||
            error.code == NSURLErrorCannotDecodeContentData {
            return .noData
        }

        return .unknownError("\(error)")
    }
}
