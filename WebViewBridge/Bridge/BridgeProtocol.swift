//
//  BridgeProtocol.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import Foundation

public enum BridgeProtocol {
    public static let handlerName = "bridge"

    public enum Kind {
        public static let response = "response"
        public static let event = "event"
    }
}
