import UIKit

final class NativeOpenExternalHandler: BridgeHandler {
    static let action = "native.app.openExternal"
    
    func handle(_ message: BridgeMessage, context: BridgeContext) {
        let urlString = (message.payload["url"] as? String) ?? "https://www.example.com"
        
        guard let url = URL(string: urlString) else {
            if let id = message.id {
                context.sendResponse(id: id, ok: false, error: "잘못된 URL")
            }
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url) { success in
                if let id = message.id {
                    context.sendResponse(id: id, ok: success, result: success ? urlString : nil, error: success ? nil : "앱 열기 실패")
                }
            }
        }
    }
}
