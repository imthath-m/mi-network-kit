//
//  Usecase.swift
//  DappStaff
//
//  Created by Imthath M on 16/01/20.
//  Copyright © 2020 SkyDevz. All rights reserved.
//

import Foundation

private let bgQueue = DispatchQueue(label: "MIUsecase")

/// Provide implementation for the execute method and then
/// call perform to get response in main thread
/// call execute to get response in background thread
public protocol MIUsecase: class {
    associatedtype MIUsecaseRequest
    associatedtype MIUsecaseResponse

    /// performs the usecase request in a common background queue
    /// and the response callback is in main thread
    func perform(_ request: MIUsecaseRequest, and callback: @escaping (MIUsecaseResponse) -> Void)

    /// executes the usecase request in a background thread
    /// and the response callback is in the same background thread
    func execute(_ request: MIUsecaseRequest, and callback: @escaping (MIUsecaseResponse) -> Void)

    /// used to perform callback in the main queue
    func invoke(_ callback: @escaping (MIUsecaseResponse) -> Void, using result: MIUsecaseResponse)
}

public extension MIUsecase {

    func perform(_ request: MIUsecaseRequest, and callback: @escaping (MIUsecaseResponse) -> Void) {
        bgQueue.async { [weak self] in
            self?.execute(request) { [weak self] result in
                self?.invoke(callback, using: result)
            }
        }
    }

    func invoke(_ callback: @escaping (MIUsecaseResponse) -> Void, using result: MIUsecaseResponse) {
        if Thread.isMainThread {
            callback(result)
            return
        }

        DispatchQueue.main.async {
            callback(result)
        }
    }

}

public class GetObject<T: Codable>: MIUsecase, MINetworkable {
    
    public typealias MIUsecaseRequest = MIRequest
    
    public typealias MIUsecaseResponse = Result<T, MINetworkError>
    
    public init() { }
    
    public func execute(_ request: MIRequest, and callback: @escaping (Result<T, MINetworkError>) -> Void) {
        send(request, returns: [T](), onCompletion: callback)
    }
}

public class GetStatusCode: MIUsecase, MINetworkable {
    
    public typealias MIUsecaseRequest = MIRequest
    
    public typealias MIUsecaseResponse = Bool
    
    let statusCode: MIResponseStatusCode
    
    public init(_ code: MIResponseStatusCode) {
        self.statusCode = code
    }

    public func execute(_ request: MIRequest, and callback: @escaping (Bool) -> Void) {
        update(request, expecting: statusCode, onCompletion: callback)
    }
}
