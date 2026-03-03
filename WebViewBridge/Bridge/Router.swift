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
            return
        }

        guard let handler = handlers[msg.action] else {
            print("BridgeRouter: no handler for action:", msg.action)
            return
        }

        handler.handle(msg, context: context)
    }
}
