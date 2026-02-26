//
//  WKNavigation.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import UIKit
import WebKit

extension BridgeInspectorViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        logger.log("🌐 Web didStartProvisionalNavigation")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logger.log("✅ Web didFinish")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        logger.log("❌ Web didFail: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logger.log("❌ Web didFailProvisional: \(error.localizedDescription)")
    }
}
