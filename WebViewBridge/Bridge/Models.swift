import Foundation

struct BridgeMessage {
    let id: String?
    let kind: String?      // kind 또는 type 둘 다 허용
    let type: String?
    let action: String
    let payload: [String: Any]

    init?(body: Any) {
        guard let dict = body as? [String: Any] else { return nil }
        guard let action = dict["action"] as? String else { return nil }

        self.id = dict["id"] as? String
        self.kind = dict["kind"] as? String
        self.type = dict["type"] as? String
        self.action = action
        self.payload = (dict["payload"] as? [String: Any]) ?? [:]
    }

    var requestType: String? { kind ?? type }
}


