//
//  BridgeLogger.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import Foundation

public protocol BridgeLogging {
    func log(_ line: String)
}

public final class BridgeLogger: BridgeLogging {
    private let store: BridgeLogStore
    public init(store: BridgeLogStore) { self.store = store }

    public func log(_ line: String) {
        store.append(line)
    }
}
