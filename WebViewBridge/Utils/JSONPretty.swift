//
//  JSONPretty.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import Foundation

public enum JSONPretty {
    public static func stringify(_ obj: Any) -> String {
        let normalized = normalize(obj)
        if JSONSerialization.isValidJSONObject(normalized),
           let data = try? JSONSerialization.data(withJSONObject: normalized, options: [.prettyPrinted]),
           let s = String(data: data, encoding: .utf8) {
            return s
        }
        if let data = try? JSONSerialization.data(withJSONObject: ["value": normalized], options: [.prettyPrinted]),
           let s = String(data: data, encoding: .utf8) {
            return s
        }
        return String(describing: obj)
    }

    private static func normalize(_ obj: Any) -> Any {
        if obj is NSNull { return obj }
        if let v = obj as? String { return v }
        if let v = obj as? Bool { return v }
        if let v = obj as? Int { return v }
        if let v = obj as? Double { return v }
        if let v = obj as? Float { return Double(v) }
        if let v = obj as? NSNumber { return v }

        if let dict = obj as? [String: Any] {
            var out: [String: Any] = [:]
            for (k, v) in dict { out[k] = normalize(v) }
            return out
        }
        if let arr = obj as? [Any] { return arr.map { normalize($0) } }
        if let date = obj as? Date { return ISO8601DateFormatter().string(from: date) }

        return String(describing: obj)
    }
}
