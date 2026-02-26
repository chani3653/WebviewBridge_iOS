//
//  BridgeLogStore.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import Foundation

public final class BridgeLogStore {
    public private(set) var lines: [String] = []
    public var onChange: (([String]) -> Void)?

    public init() {}

    public func append(_ line: String) {
        let ts = ISO8601DateFormatter().string(from: Date())
        lines.append("[\(ts)] \(line)")
        if lines.count > 500 { lines.removeFirst(lines.count - 500) }
        onChange?(lines)
    }

    public func clear() {
        lines.removeAll()
        onChange?(lines)
    }
}
