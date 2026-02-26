//
//  WebMessage.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import UIKit
import WebKit

extension BridgeInspectorViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == BridgeProtocol.handlerName else { return }

        guard let dict = BridgeInbound.parse(message.body) else {
            logger.log("⬅️ [WEB] unsupported body: \(String(describing: message.body))")
            return
        }

        let kind = BridgeInbound.kind(dict)

        if kind == BridgeProtocol.Kind.response {
            handleWebResponse(dict)
            return
        }

        if kind == BridgeProtocol.Kind.event {
            handleWebEvent(dict)
            return
        }

        logger.log("⬅️ [WEB] \(JSONPretty.stringify(dict))")
    }

    private func handleWebResponse(_ dict: [String: Any]) {
        let id = dict["id"] as? String ?? "-"
        let ok = (dict["ok"] as? Bool) ?? false
        let data = dict["data"] ?? NSNull()
        let error = dict["error"] ?? NSNull()

        let durationDesc: String
        if let meta = dict["meta"] as? [String: Any],
           let ms = meta["durationMs"] {
            durationDesc = " duration=\(ms)ms"
        } else {
            durationDesc = ""
        }

        logger.log("⬅️ [RES] id=\(id) ok=\(ok)\(durationDesc)\ndata=\(JSONPretty.stringify(data))\nerror=\(JSONPretty.stringify(error))")
    }

    private func handleWebEvent(_ dict: [String: Any]) {
        let type = dict["type"] as? String ?? "-"
        let payload = dict["payload"] ?? NSNull()
        logger.log("⬅️ [EVT] \(type)\npayload=\(JSONPretty.stringify(payload))")
    }
}
