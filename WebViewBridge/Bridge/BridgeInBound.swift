//
//  BridgeInBound.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import Foundation

public enum BridgeInbound {
    public static func parse(_ body: Any) -> [String: Any]? {
        if let dict = body as? [String: Any] { return dict }
        return nil
    }

    public static func kind(_ dict: [String: Any]) -> String? {
        dict["kind"] as? String
    }
}
