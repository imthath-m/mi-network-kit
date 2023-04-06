//
//  MIUploader.swift
//  UtilitiesExample
//
//  Created by Imthath M on 29/07/19.
//  Copyright © 2019 SkyDevz. All rights reserved.
//

import Foundation

public protocol MIUploaderDelegate: AnyObject {
  func uploaded(fraction: Float)
}

/// Use NetworkUploaderDelegate to stream the progress and get the percentage of file uploaded
public class MIUploader: NSObject, MINetworkable, URLSessionTaskDelegate {
  weak private var delegate: MIUploaderDelegate?

  public init(delegate: MIUploaderDelegate) {
    self.delegate = delegate
  }

  lazy public var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)

  public func uploadFile(from url: URL, using request: URLRequest, onCompletion handler: @escaping (Result<Data, MINetworkError>) -> Void) {
    session.uploadTask(with: request, fromFile: url) { data, response, error in
        handler(self.process(data, response, error))
      }.resume()
  }

  public func uploadData(_ data: Data?, using request: URLRequest, onCompletion handler: @escaping (Result<Data, MINetworkError>) -> Void) {
    session.uploadTask(with: request, from: data) { data, response, error in
        handler(self.process(data, response, error))
      }.resume()
  }

  public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    delegate?.uploaded(fraction: Float(totalBytesSent / totalBytesExpectedToSend))
  }
}

public extension MINetworkable {
  /// The stream ends when one of the returned data can't be decoded to the expected type.
  func responseStream<AnyDecodable: Decodable>(from request: MIRequestable) throws -> AsyncStream<AnyDecodable> {
    try responseStream(from: request.urlRequest())
  }

  /// The stream ends when one of the returned data can't be decoded to the expected type.
  func responseStream<AnyDecodable: Decodable>(from urlRequest: URLRequest) -> AsyncStream<AnyDecodable> {
    AsyncStream { continuation in
      MIStreamer(request: urlRequest).observe { data in
        do {
          let result: AnyDecodable = try JSONDecoder().decode(AnyDecodable.self, from: data)
          continuation.yield(result)
        } catch {
          debugPrint("Error \(error.localizedDescription)")
          continuation.finish()
        }
      }
    }
  }
}

/// Use when the endpoint supports streaming of data
private class MIStreamer: NSObject, URLSessionDataDelegate {
  let request: URLRequest
  var dataHandler: ((Data) -> Void)?

  public init(request: URLRequest) {
    self.request = request
  }

  lazy public var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)

  public func observe(dataChange: @escaping (Data) -> Void) {
    session.dataTask(with: request).resume()
    dataHandler = dataChange
  }

  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    dataHandler?(data)
  }
}
