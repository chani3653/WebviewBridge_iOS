# WebViewBridge iOS

iOS 네이티브와 WebView 간 양방향 브릿지 통신을 구현한 프로젝트입니다.

웹에서 `postMessage`로 네이티브 기능을 호출하고, 네이티브에서 `sendResponse`/`sendCommand`로 웹에 응답하는 구조입니다.

---

## 프로젝트 구조

```
WebViewBridge/
├── Bridge/                           # 브릿지 통신 인프라
│   ├── Context.swift                 # 메시지 송수신 컨텍스트
│   ├── Models.swift                  # BridgeMessage 데이터 모델
│   ├── Router.swift                  # 액션 기반 핸들러 라우팅
│   ├── Toast.swift                   # Toast UI 확장
│   └── Handler/                      # 네이티브 기능 핸들러
│       ├── NativeTokenHandler.swift  # 토큰 생성/반환
│       ├── UIToast.swift             # 토스트 메시지 표시
│       ├── Push.swift                # 푸시 알림 권한 요청 및 로컬 알림
│       └── Vibrate.swift             # CoreHaptics 진동 피드백
│
├── MainViewController/               # 메인 화면
│   ├── MainViewController.swift      # WebView + 디버깅 UI
│   ├── Extension/
│   │   ├── WebViewExtension.swift    # WKScriptMessageHandler 구현
│   │   └── TableViewExtension.swift  # TableView DataSource/Delegate
│   ├── Model/
│   │   ├── FunctionItem.swift        # 테스트 기능 모델
│   │   └── LogItem.swift             # 통신 로그 모델
│   └── View/
│       ├── FunctionTableViewCell     # 기능 목록 셀
│       ├── LogTableViewCell          # 통신 로그 셀
│       └── DataTableViewCell         # UserDefaults 데이터 셀
```

---

## 통신 프로토콜

### 메시지 형식

모든 통신은 JSON 기반으로 이루어집니다.

**Request (웹 → 네이티브)**
```json
{
  "id": "req-12345",
  "kind": "request",
  "action": "native.token.get",
  "payload": {}
}
```

**Response (네이티브 → 웹)**
```json
{
  "kind": "response",
  "id": "req-12345",
  "ok": true,
  "result": "ios-uuid-string"
}
```

**Command (네이티브 → 웹, 응답 없음)**
```json
{
  "kind": "command",
  "action": "push.permission",
  "payload": { "granted": true }
}
```

### 통신 흐름

```
웹 (JavaScript)                              네이티브 (Swift)
      │                                            │
      │  postMessage({ action, payload })          │
      ├───────────────────────────────────────────→│
      │                                            ├─ Router.route()
      │                                            ├─ Handler.handle()
      │                                            │
      │  window.onNativeMessage({ ok, result })    │
      │←───────────────────────────────────────────┤
      │                                            │
```

---

## 등록된 핸들러

| 액션 | 핸들러 | 기능 | Payload |
|------|--------|------|---------|
| `native.token.get` | NativeTokenHandler | UUID 토큰 생성 및 반환 | - |
| `native.ui.toast` | NativeUIToastHandler | 토스트 메시지 표시 | `{ message: string }` |
| `native.push.requestPermission` | NativePushHandler | 푸시 권한 요청 + 로컬 알림 | `{ title, body, delay }` |
| `native.haptic.vibrate` | NativeHapticComboHandler | 진동 피드백 | `{ duration, peak }` |

---

## 핸들러 추가 방법

`BridgeHandler` 프로토콜을 구현하고 Router에 등록하면 됩니다.

```swift
final class MyHandler: BridgeHandler {
    static let action = "native.my.action"

    func handle(_ message: BridgeMessage, context: BridgeContext) {
        guard let id = message.id else { return }

        // 네이티브 기능 수행
        let result = "처리 완료"

        // 웹으로 응답
        context.sendResponse(id: id, ok: true, result: result)
    }
}
```

```swift
// MainViewController.setWebView()에서 등록
router.register(MyHandler())
```

---

## 디버깅 UI

화면 하단의 탭으로 전환할 수 있는 3개의 패널이 있습니다.

| 탭 | 기능 |
|----|------|
| **기능** | 테스트 함수 목록 (얼럿, 토큰 조회, 페이지 이동, 토큰 저장) |
| **콘솔** | 브릿지 통신 로그 (방향, 상태, 메시지 내용 실시간 표시) |
| **데이터** | UserDefaults 저장소의 키-값 조회 |

### 콘솔 로그 색상

**상태별:**
- 대기 — 회색
- 성공 — 연두색
- 실패 — 주황색

**방향별:**
- Web → Native — 하늘색
- Native → Web — 연보라색

---

## 웹 측 연동

웹에서 브릿지를 사용하려면 아래 두 가지가 필요합니다.

### 1. 네이티브 호출

```javascript
window.webkit.messageHandlers.bridge.postMessage({
  id: "unique-id",
  kind: "request",
  action: "native.ui.toast",
  payload: { message: "안녕하세요!" }
});
```

### 2. 응답 수신

```javascript
window.onNativeMessage = (msg) => {
  const { id, kind, ok, result, error } = msg;
  if (kind === "response") {
    // id로 매칭하여 처리
  }
};
```

---

## 기술 스택

- **UI:** UIKit (Storyboard + XIB)
- **WebView:** WKWebView
- **통신:** WKScriptMessageHandler
- **알림:** UserNotifications
- **진동:** CoreHaptics
- **저장소:** UserDefaults
