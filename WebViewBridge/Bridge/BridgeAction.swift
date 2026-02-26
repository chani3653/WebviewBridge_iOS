//
//  BridgeAction.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import Foundation

public struct BridgeActionItem {
    public let title: String
    public let action: String
    public let payload: [String: Any]

    public init(title: String, action: String, payload: [String: Any]) {
        self.title = title
        self.action = action
        self.payload = payload
    }
}
