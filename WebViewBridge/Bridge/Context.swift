import UIKit
import WebKit

struct BridgeContext {
    weak var viewController: UIViewController?
    weak var webView: WKWebView?

    func showToast(_ text: String) {
        guard let vc = viewController else { return }
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        vc.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }

    func evalJS(_ js: String) {
        webView?.evaluateJavaScript(js) { _, error in
            if let error = error { print("evaluateJS error:", error) }
        }
    }
    
    func sendResponse(id: String, ok: Bool, result: Any? = nil, error: String? = nil) {
        var obj: [String: Any] = [
            "kind": "response",
            "id": id,
            "ok": ok
        ]
        if let result { obj["result"] = result }
        if let error { obj["error"] = error }

        guard
            let data = try? JSONSerialization.data(withJSONObject: obj, options: []),
            let json = String(data: data, encoding: .utf8)
        else {
            return
        }

        let js = "window.onNativeMessage && window.onNativeMessage(\(json))"
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(js) { _, err in
                if let err { print("evalJS error:", err) }
            }
        }
        print("RUN sendResponse data:\(js)")
    }
}
