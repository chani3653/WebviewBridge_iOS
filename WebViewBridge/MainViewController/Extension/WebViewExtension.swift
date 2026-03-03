import WebKit

extension MainViewController: WKNavigationDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("웹 로딩 시작")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹 로딩 완료")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("웹 로딩 실패: \(error)")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "bridge" else { return }

        router.route(body: message.body)
    }

    private func showToast(_ text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
}

