//
//  AnyJson.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//

import Foundation

public struct AnyJSON: Codable {
    public let value: Any
    public init(_ value: Any) { self.value = value }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Bool.self) { value = v; return }
        if let v = try? c.decode(Int.self) { value = v; return }
        if let v = try? c.decode(Double.self) { value = v; return }
        if let v = try? c.decode(String.self) { value = v; return }
        if let v = try? c.decode([String: AnyJSON].self) { value = v; return }
        if let v = try? c.decode([AnyJSON].self) { value = v; return }
        if c.decodeNil() { value = NSNull(); return }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "AnyJSON decode failed")
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let v as Bool: try c.encode(v)
        case let v as Int: try c.encode(v)
        case let v as Double: try c.encode(v)
        case let v as String: try c.encode(v)
        case let v as [String: AnyJSON]: try c.encode(v)
        case let v as [AnyJSON]: try c.encode(v)
        case is NSNull: try c.encodeNil()
        default: try c.encode(String(describing: value))
        }
    }
}
