import Foundation

protocol BridgeHandler {
    static var action: String { get }
    func handle(_ message: BridgeMessage, context: BridgeContext)
}

final class BridgeRouter {
    private var handlers: [String: BridgeHandler] = [:]
    private let context: BridgeContext

    init(context: BridgeContext) {
        self.context = context
    }

    func register(_ handler: BridgeHandler) {
        handlers[type(of: handler).action] = handler
    }

    func route(body: Any) {
        guard let msg = BridgeMessage(body: body) else {
            print("BridgeRouter: invalid message body")
            context.onLog?(.webToNative, .failure, "unknown", "invalid message body")
            return
        }

        // 웹 → 네이티브 수신 로그
        let detail: String
        if let data = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
           let json = String(data: data, encoding: .utf8) {
            detail = json
        } else {
            detail = "\(body)"
        }
        
        guard let handler = handlers[msg.action] else {
            print("BridgeRouter: no handler for action:", msg.action)
            context.onLog?(.webToNative, .failure, msg.action, "핸들러 없음\n\(detail)")
            return
        }

        context.onLog?(.webToNative, .success, msg.action, detail)
        handler.handle(msg, context: context)
    }
}
