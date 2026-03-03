import Foundation
import UserNotifications

final class NativePushHandler: BridgeHandler {

    static let action = "native.push.requestPermission"

    func handle(_ message: BridgeMessage, context: BridgeContext) {
        requestPermission(context: context)
        showLocalNotification(message: message)
    }

    // MARK: - Permission

    private func requestPermission(context: BridgeContext) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error { print("push permission error:", error) }
            print("push permission granted:", granted)

            let js = "window.onNativeMessage && window.onNativeMessage({type:'push.permission', granted:\(granted ? "true" : "false")})"
            DispatchQueue.main.async {
                context.evalJS(js)
            }
        }
    }

    // MARK: - Local Notification

    private func showLocalNotification(message: BridgeMessage) {
        let title = (message.payload["title"] as? String) ?? "알림"
        let body  = (message.payload["body"] as? String) ?? "웹에서 요청한 알림입니다."
        let delay = (message.payload["delay"] as? Double) ?? 0.1

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let identifier = message.id ?? UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(0.1, delay), repeats: false)
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(req) { error in
            if let error { print("local notification error:", error) }
        }
    }

    // MARK: - Optional: legacy support (기존 액션 유지하고 싶을 때)

    private func handleLegacyActions(message: BridgeMessage, context: BridgeContext) {
            requestPermission(context: context)
            showLocalNotification(message: message)
    }
}
