//
//  Utilities.swift
//  ZDPortalNetworkKit
//
//  Created by Imthath M on 13/08/19.
//  Copyright © 2019 Zoho Corp. All rights reserved.
//

import Foundation

extension Encodable {

    public var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    public var jsonString: String? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return String(data: try encoder.encode(self), encoding: .utf8)
        } catch {
            return nil
        }
    }

}
extension String {

    public func log() {
        print(self)
    }

    public var encoded: String? {
        let characterSet = CharacterSet(charactersIn: "=+&:,'\"#%/<>?@\\^`{|} ")

        if let result = self.addingPercentEncoding(withAllowedCharacters: characterSet.inverted) {
            return result
        }

        return nil
    }
}

protocol Debuggable: Codable, CustomStringConvertible { }

extension Debuggable {
    public var description: String { return "\(self.jsonString ?? "NIL")"}
}

extension Optional {

    public var isNil: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }
}

extension Optional where Wrapped == Bool {

    public var value: Bool {
        switch self {
        case .none:
            return false
        case .some(let value):
            return value
        }
    }
}

extension Optional where Wrapped == Dictionary<String, Any> {
    
    public func inserted(_ value: Any, forKey key: String) -> Wrapped {
        if var strongSelf = self {
            strongSelf[key] = value
            return strongSelf
        }
        
        return [key: value]
    }
}

extension Data {
    public var dictionary: [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .mutableLeaves) as? [String: Any]
        } catch {
            return nil
        }
    }
}
