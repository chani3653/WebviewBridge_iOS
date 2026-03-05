import Foundation
import WebKit

// MARK: - Function Model

struct FunctionItem {
    let name: String
    let action: () -> Void
}

extension FunctionItem {
    static func createFunctionList(context: BridgeContext) -> [FunctionItem] {
        return [
            FunctionItem(name: "웹뷰 얼럿 띄우기") {
                context.webView?.evaluateJavaScript("alert('네이티브에서 호출한 얼럿입니다!');")
            },
            FunctionItem(name: "웹뷰 토큰 가져오기") {
                let script = """
                (function() {
                    const token = localStorage.getItem('token') || sessionStorage.getItem('token');
                    return token;
                })();
                """
                context.webView?.evaluateJavaScript(script) { result, error in
                    if let error = error {
                        print("토큰 가져오기 실패:", error)
                        return
                    }
                    if let token = result as? String {
                        print("가져온 토큰:", token)
                        context.viewController?.showToast(message: "토큰: \(token)")
                    } else {
                        print("토큰이 없습니다")
                        context.viewController?.showToast(message: "저장된 토큰이 없습니다")
                    }
                }
            },
            FunctionItem(name: "웹뷰 페이지 이동 (example.com)") {
                if let url = URL(string: "https://www.example.com") {
                    let request = URLRequest(url: url)
                    context.webView?.load(request)
                }
            },
            FunctionItem(name: "웹뷰에 네이티브 토큰 저장") {
                let token = "ios-\(UUID().uuidString)"
                let script = "localStorage.setItem('token', '\(token)');"
                context.webView?.evaluateJavaScript(script) { _, error in
                    if let error = error {
                        print("토큰 저장 실패:", error)
                        context.viewController?.showToast(message: "토큰 저장 실패")
                        return
                    }
                    print("웹뷰 localStorage에 토큰 저장:", token)
                    context.viewController?.showToast(message: "토큰 저장 완료: \(token)")
                }
            }
        ]
    }
}
