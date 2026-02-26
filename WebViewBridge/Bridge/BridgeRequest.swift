//
//  BirdgeRequest.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import Foundation

public struct BridgeRequest {
    public let id: String
    public let action: String
    public let payload: [String: Any]
    public init(id: String, action: String, payload: [String: Any]) {
        self.id = id
        self.action = action
        self.payload = payload
    }
}
