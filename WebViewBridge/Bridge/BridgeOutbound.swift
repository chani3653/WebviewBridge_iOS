//
//  BridgeOutbound.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import Foundation
import WebKit

public final class BridgeOutbound {
    private weak var webView: WKWebView?
    private let logger: BridgeLogging

    public init(webView: WKWebView, logger: BridgeLogging) {
        self.webView = webView
        self.logger = logger
    }

    public func sendRequest(_ req: BridgeRequest) {
        let obj: [String: Any] = [
            "id": req.id,
            "action": req.action,
            "payload": req.payload,
            "meta": ["source": "ios", "ts": Int64(Date().timeIntervalSince1970 * 1000)]
        ]

        callJS(functionName: "__bridgeReceiveFromNative", object: obj)
    }

    public func emitEvent(type: String, payload: [String: Any]) {
        let obj: [String: Any] = [
            "type": type,
            "payload": payload,
            "meta": ["ts": Int64(Date().timeIntervalSince1970 * 1000)]
        ]

        callJS(functionName: "__bridgeEmitEventFromNative", object: obj)
    }

    private func callJS(functionName: String, object: [String: Any]) {
        guard let webView else { return }

        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []),
              var json = String(data: data, encoding: .utf8) else {
            logger.log("❌ JSONSerialization failed for \(functionName)")
            return
        }

        json = json
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")

        // ✅ Promise/복잡 객체 반환 방지: 항상 문자열만 반환
        let js = """
        (function(){
          try {
            if (typeof window.\(functionName) !== 'function') { return 'NO_FN'; }
            window.\(functionName)(JSON.parse('\(json)'));
            return 'OK';
          } catch(e) {
            return 'ERR:' + (e && e.message ? e.message : String(e));
          }
        })();
        """

        webView.evaluateJavaScript(js) { [weak self] result, error in
            if let error = error {
                self?.logger.log("❌ JS error: \(error.localizedDescription)")
                return
            }
            if let s = result as? String {
                if s == "NO_FN" {
                    self?.logger.log("⚠️ Web function not ready: \(functionName)")
                } else if s.hasPrefix("ERR:") {
                    self?.logger.log("❌ JS error: \(s)")
                }
            }
        }
    }
}
