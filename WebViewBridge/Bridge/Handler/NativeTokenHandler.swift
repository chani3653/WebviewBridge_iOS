import Foundation

final class NativeTokenHandler: BridgeHandler {
    static let action = "native.token.get"

    func handle(_ message: BridgeMessage, context: BridgeContext) {
        // 요청 id 없으면 응답 매칭 불가
        guard let id = message.id else { return }

        // ✅ 토큰 생성 (원하는 방식으로 바꿔도 됨)
        let token = "ios-\(UUID().uuidString)"

        // ✅ 웹으로 응답
        context.sendResponse(id: id, ok: true, result: token)
    }
}
