import Foundation

final class NativeUIToastHandler: BridgeHandler {
    static let action = "native.ui.toast"

    func handle(_ message: BridgeMessage, context: BridgeContext) {
        let msg = (message.payload["message"] as? String) ?? "NO MESSAGE"
        context.showToast(msg)
    }
}
