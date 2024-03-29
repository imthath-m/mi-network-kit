//
//  MINetworkable.swift
//  UtilitiesExample
//
//  Created by Imthath M on 26/07/19.
//  Copyright © 2019 SkyDevz. All rights reserved.
//

// swiftlint:disable line_length

import Foundation

public typealias MIResponseStatusCode = Int

public protocol MINetworkable {

  var session: URLSession { get }

  var decoder: JSONDecoder { get }

  // MARK:- methods to work with MIRequest

  func update(_ myRequest: MIRequestable, expecting code: MIResponseStatusCode, onCompletion handler: @escaping (Bool) -> Void)

  func send<AnyDecodable: Decodable>(_ myRequest: MIRequestable, returns responseAs: [AnyDecodable], onCompletion handler: @escaping (Result<AnyDecodable, MINetworkError>) -> Void)

  func getData(from myRequest: MIRequestable, onCompletion handler: @escaping (Result<Data, MINetworkError>) -> Void)

  // MARK:- methods to work with Foundation's URLRequest

  func hit(_ request: URLRequest, expecting code: MIResponseStatusCode, onCompletion handler: @escaping (Bool) -> Void)

  func getTaskAndSend(_ request: URLRequest, onCompletion handler: @escaping (Result<Data, MINetworkError>) -> Void) -> URLSessionTask

  func get<AnyDecodable: Decodable>(_ type: AnyDecodable.Type, from request: URLRequest, onCompletion handler: @escaping (Result<AnyDecodable, MINetworkError>) -> Void)


  func postJSON<AnyEncodable: Encodable, AnyDecodable: Decodable>(
    of object: AnyEncodable,
    using request: inout URLRequest,
    forResponseType: AnyDecodable.Type,
    onCompletion handler: @escaping (Result<AnyDecodable, MINetworkError>) -> Void
  )

  // MARK:- Helper methods
  func checkStatusCode(isSameAs code: MIResponseStatusCode, _ data: Data?, _ response: URLResponse?, _ error: Error?) -> Bool

  func process(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Data, MINetworkError>

  func parse<AnyDecodable: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<AnyDecodable, MINetworkError>

  func parseResult<AnyDecodable: Decodable>(from data: Data?) -> Result<AnyDecodable, MINetworkError>
}

// MARK:- methods to work with Foundation's URLRequest
public extension MINetworkable {
  var session: URLSession { URLSession.shared }
  var decoder: JSONDecoder { JSONDecoder() }

  func getTaskAndSend(_ request: URLRequest,
                      onCompletion handler: @escaping (Result<Data, MINetworkError>) -> Void) -> URLSessionTask {
    let task = session.dataTask(with: request) { data, response, error in
      handler(self.process(data, response, error))
    }
    task.resume()
    return task
  }

  func hit(_ request: URLRequest, expecting code: MIResponseStatusCode,
           onCompletion handler: @escaping (Bool) -> Void) {
    session.dataTask(with: request) { (data, response, error) in
        handler(self.checkStatusCode(isSameAs: code, data, response, error))
      }
      .resume()
  }

  func get<AnyDecodable: Decodable>(_ type: AnyDecodable.Type, from request: URLRequest,
                                    onCompletion handler: @escaping (Result<AnyDecodable, MINetworkError>) -> Void) {
    session.dataTask(with: request) { data, response, error in
        handler(self.parse(data, response, error))
      }
      .resume()
  }

  func postJSON<AnyEncodable: Encodable, AnyDecodable: Decodable>(of object: AnyEncodable, using request: inout URLRequest,
                                                                  forResponseType: AnyDecodable.Type,
                                                                  onCompletion handler: @escaping (Result<AnyDecodable, MINetworkError>) -> Void) {
    request.httpBody = object.jsonData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    get(AnyDecodable.self, from: request, onCompletion: handler)
  }
}

// MARK:- methods to work with MIRequest
public extension MINetworkable {
  func update(_ myRequest: MIRequestable, expecting code: MIResponseStatusCode, onCompletion handler: @escaping (Bool) -> Void) {
    do {
      let request = try myRequest.urlRequest()
      hit(request, expecting: code, onCompletion: handler)
    } catch {
      "\(error)".log()
      handler(false)
    }
  }

  func send<T: Decodable>(_ myRequest: MIRequestable, returns responseAs: [T], onCompletion handler: @escaping (Result<T, MINetworkError>) -> Void) {
    do {
      let request = try myRequest.urlRequest()
      get(T.self, from: request, onCompletion: handler)
    } catch {
      "\(error)".log()
      handler(.failure(MINetworkError(error: error)))
    }
  }

  func getData(from myRequest: MIRequestable, onCompletion handler: @escaping (Result<Data, MINetworkError>) -> Void) {
    do {
      let request = try myRequest.urlRequest()
      session.dataTask(with: request) { data, response, error in
        handler(self.process(data, response, error))
      }.resume()
    } catch {
      "\(error)".log()
      handler(.failure(MINetworkError(error: error)))
    }
  }
}

// MARK:- Helper Methods
public extension MINetworkable {
  func checkStatusCode(isSameAs code: MIResponseStatusCode, _ data: Data?, _ response: URLResponse?, _ error: Error?) -> Bool {
    guard error.isNil,
          let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == code
    else {
      return false
    }

    return true
  }

  func process(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Data, MINetworkError> {
    if let systemError = error {
      return .failure(MINetworkError.parse(error: systemError as NSError))
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      return .failure(.badResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      return .failure(.invalidStatusCode(httpResponse.statusCode))
    }

    guard let existingData = data else {
      return .failure(.noData)
    }

    return .success(existingData)
  }

  func parse<AnyDecodable: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<AnyDecodable, MINetworkError> {
    if let systemError = error {
      return .failure(MINetworkError.parse(error: systemError as NSError))
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      return .failure(.badResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      return .failure(.invalidStatusCode(httpResponse.statusCode))
    }

    return parseResult(from: data)
  }

  func parseResult<AnyDecodable: Decodable>(from data: Data?) -> Result<AnyDecodable, MINetworkError> {
    guard let existingData = data else {
      return .failure(.noData)
    }

    do {
      return .success(try decoder.decode(AnyDecodable.self, from: existingData))
    } catch let error {
      return .failure(.decodingFailed(existingData, error))
    }
  }
}
