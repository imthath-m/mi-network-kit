//
//  NetworkUploader.swift
//  UtilitiesExample
//
//  Created by Imthath M on 29/07/19.
//  Copyright © 2019 Zoho Corp. All rights reserved.
//

import Foundation

public protocol MINetworkUploaderDelegate: class {
    func uploaded(fraction: Float)
}

/// Use NetworkUploaderDelegate to stream the progress and get the percentage of file uploaded
public class MINetworkUploader: NSObject, MINetworkable, URLSessionTaskDelegate {

    weak var delegate: NetworkUploaderDelegate?

    public init(delegate: NetworkUploaderDelegate) {
        self.delegate = delegate
    }

    lazy public var session = {
        URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }()

    public func uploadFile(from url: URL, using request: URLRequest,
                           onCompletion handler: @escaping (Result<Data, MINetworkError>) -> Void) {
        session.uploadTask(with: request, fromFile: url) { data, response, error in
            handler(self.process(data, response, error))
            }.resume()
    }

    public func uploadData(_ data: Data?, using request: URLRequest,
                           onCompletion handler: @escaping (Result<Data, MINetworkError>) -> Void) {
        session.uploadTask(with: request, from: data) { data, response, error in
            handler(self.process(data, response, error))
            }.resume()
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        delegate?.uploaded(fraction: Float(totalBytesSent / totalBytesExpectedToSend))
    }
}
