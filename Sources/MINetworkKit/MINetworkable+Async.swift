//
// Created by Imthathullah on 17/01/23.
//

import Foundation

// MARK: - Swift Concurrency alternatives with async throwing functions
public extension MINetworkable {
  func hit(_ myRequest: MIRequest, expecting code: MIResponseStatusCode) async throws -> Bool {
    let request = try getURLRequest(from: myRequest)
    return try await hit(request, expecting: code)
  }

  func get<T: Decodable>(from myRequest: MIRequest) async throws -> T {
    let request = try getURLRequest(from: myRequest)
    return try await get(from: request)
  }

  func getData(from myRequest: MIRequest) async throws -> Data {
    let request = try getURLRequest(from: myRequest)
    return try await getData(from: request)
  }
}

private extension MINetworkable {
  func hit(_ request: URLRequest, expecting code: MIResponseStatusCode) async throws -> Bool {
    let (_, response) = try await session.responseData(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == code else {
      return false
    }
    return true
  }

  func get<AnyDecodable: Decodable>(from request: URLRequest) async throws -> AnyDecodable {
    let data: Data = try await getData(from: request)
    return try JSONDecoder().decode(AnyDecodable.self, from: data)
  }

  func getData(from request: URLRequest) async throws -> Data {
    let (data, _) = try await session.responseData(for: request)
    return data
  }
}

private extension URLSession {
  func responseData(for request: URLRequest) async throws -> (Data, URLResponse) {
    do {
      let (data, response) = try await data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw MINetworkError.badResponse
      }
      guard (200...299).contains(httpResponse.statusCode) else {
        throw MINetworkError.invalidStatusCode(httpResponse.statusCode)
      }
      return (data, response)
    } catch {
      throw MINetworkError.parse(error: error as NSError)
    }
  }
}
