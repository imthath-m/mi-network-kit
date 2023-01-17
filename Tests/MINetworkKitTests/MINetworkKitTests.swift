import XCTest
@testable import MINetworkKit

final class MINetworkKitTests: XCTestCase, MINetworkable {
  func testAsyncNetworkCalls() async throws {
    let posts: [Post] = try await get(from: "https://jsonplaceholder.typicode.com/posts")
    print(posts.count)
    XCTAssert(posts.count > 0)

    let albums: [Album] = try await get(from: TypicodeRequest.getAlbums)
    print(albums.count)
    XCTAssert(albums.count > 0)

    guard let commentsURL: URL = URL(string: "https://jsonplaceholder.typicode.com/comments") else {
      XCTFail("Unable to form url")
      return
    }
    let comments: [Comment] = try await get(from: commentsURL)
    print(comments.count)
    XCTAssert(comments.count > 0)
  }
}

enum TypicodeRequest: MIRequest {
  case getPosts
  case getAlbums
  case getComments

  var urlString: String {
    switch self {
    case .getPosts:
      return "https://jsonplaceholder.typicode.com/posts"
    case .getAlbums:
      return "https://jsonplaceholder.typicode.com/albums"
    case .getComments:
      return "https://jsonplaceholder.typicode.com/comments"
    }
  }

  var method: MINetworkMethod { .get }

  var params: [String : Any]? { nil }

  var headers: [String : String]? { nil }

  var body: Data? { nil }
}

struct Post: Codable {
  let userId, id: Int
  let title, body: String
}

struct Album: Codable {
  let userId, id: Int
  let title: String
}

struct Comment: Codable {
  let postId, id: Int
  let name, email, body: String
}
