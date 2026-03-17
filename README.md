# 📱 iOS Bridge Web Module

iOS `WKWebView` 환경에서 동작하는 **Web ↔ Native 브릿지 테스트용 React/Vite 모듈**이다.  
이 모듈은 Native 기능 호출, 응답 수신, 로그 확인, 로컬 데이터 확인을 한 화면 안에서 검증할 수 있도록 설계되었다.

---

## Overview

이 프로젝트는 iOS 네이티브 앱에 탑재되는 WebView 화면을 기준으로 작성되었으며,  
웹 단에서 다음 기능을 테스트하기 위한 목적을 가진다.

- Web → Native 요청 전송
- Native → Web 응답 수신
- 브릿지 통신 로그 시각화
- 웹 저장소(LocalStorage) 확인

압축 파일 기준으로 확인된 구조는 **React 19 + Vite 7** 기반이며,  
핵심 브릿지 로직은 `src/Bridge/BridgeAction.js`에서 처리된다.

---

## Tech Stack

| Item | Value |
|------|-------|
| Framework | React 19 |
| Bundler | Vite 7 |
| Language | JavaScript (ES Modules) |
| UI Style | Custom CSS |
| Target Runtime | iOS WKWebView |
| Bridge Entry | `window.webkit.messageHandlers.bridge.postMessage(...)` |

---

## Project Structure

~~~text
project-root
├── index.html
├── package.json
├── vite.config.js
├── src
│   ├── App.jsx
│   ├── main.jsx
│   ├── index.css
│   ├── Bridge
│   │   ├── BridgeAction.js
│   │   └── ConsoleAction.js
│   ├── Components
│   │   └── Tabs.jsx
│   ├── Pages
│   │   ├── Functions.jsx
│   │   ├── Console.jsx
│   │   └── Storage.jsx
│   └── Storage
│       └── StorageAction.js
└── public
    └── vite.svg
~~~

---

## Screen Composition

이 모듈은 상단 탭 구조를 기반으로 3개의 주요 화면을 제공한다.

| Tab | Description |
|-----|-------------|
| 기능 | Native 기능 호출 테스트 |
| 콘솔 | Web ↔ Native 로그 확인 |
| 데이터 | LocalStorage 데이터 확인 |

---

## Core Features

### 1. Native Function Test

`Functions.jsx`에서는 버튼 기반으로 여러 Native 액션을 호출할 수 있다.

현재 확인된 호출 항목:

| Action | Description |
|--------|-------------|
| `native.haptic.vibrate` | 진동 호출 |
| `native.push.requestPermission` | 푸시 권한 요청 |
| `native.token.get` | 토큰 조회 |
| `native.ui.toast` | 토스트 메시지 표시 |
| `native.app.openExternal` | 외부 URL 열기 |

---

### 2. Promise-Based Bridge Request

`requestNative()`는 고유 ID를 생성하고,  
`pending Map`에 요청 상태를 저장한 뒤 Promise 형태로 Native 응답을 기다린다.

주요 특징:

- request id 자동 생성
- timeout 기본 8000ms
- response 수신 시 resolve / reject 처리
- 브릿지 미연결 시 즉시 실패 처리

---

### 3. Native Response Receiver

웹에서는 전역 함수 `window.onNativeMessage`를 통해  
네이티브가 전달하는 response/event 메시지를 수신한다.

이 구조를 통해 다음이 가능하다.

- request-response 매칭
- 성공 / 실패 판별
- 로그 기록 동기화

---

### 4. Log Viewer

`ConsoleAction.js`는 인메모리 로그 저장소 역할을 하며,  
요청과 응답을 각각 기록하고 콘솔 화면에 표시한다.

로그 특징:

- 최신순 정렬
- 최대 200개 유지
- elapsed time 계산
- Success / Fail / Neutral 상태 구분

---

### 5. Storage Viewer

`Storage.jsx`는 현재 웹의 `localStorage`를 읽어서  
키-값 단위로 화면에 출력한다.

특징:

- 키 기준 정렬
- JSON 문자열이면 pretty print 처리
- 문자열이면 그대로 표시

---

## Bridge Flow

~~~text
[Web Button Click]
        ↓
create request message
        ↓
window.webkit.messageHandlers.bridge.postMessage(...)
        ↓
[iOS Native]
        ↓
Native handles action
        ↓
window.onNativeMessage(response)
        ↓
pending request resolve / reject
        ↓
Console log update
~~~

---

## Key Files

| File | Role |
|------|------|
| `src/App.jsx` | 전체 탭/레이아웃 구성 |
| `src/Bridge/BridgeAction.js` | 브릿지 송수신 핵심 로직 |
| `src/Bridge/ConsoleAction.js` | 로그 저장 및 상태 관리 |
| `src/Pages/Functions.jsx` | Native 액션 테스트 UI |
| `src/Pages/Console.jsx` | 로그 출력 UI |
| `src/Pages/Storage.jsx` | LocalStorage 확인 UI |
| `src/Components/Tabs.jsx` | 상단 탭 UI |

---

## Development Environment

로컬 개발 서버는 Vite 설정 기준 아래와 같이 구성되어 있다.

| Item | Value |
|------|-------|
| Host | `0.0.0.0` |
| Port | `5173` |
| Strict Port | `true` |

즉, iOS 시뮬레이터나 실기기에서 같은 네트워크를 통해  
개발 서버 접속 테스트를 고려한 설정으로 볼 수 있다.

---

## Observations from Analysis

압축 파일 분석 기준으로 확인된 특징은 다음과 같다.

- `node_modules`가 포함되어 있어 저장소 업로드 시 불필요하게 무거워질 수 있음
- `__MACOSX`, `.DS_Store`, `src/Console /ConsoleAction.js` 같은 정리 대상이 존재함
- `StorageAction.js`는 현재 비어 있음
- 현재 문서는 “순수 iOS 네이티브 소스”보다 “iOS WebView 테스트 웹 모듈”에 더 가까움

---

## Cleanup Recommendations

| Item | Recommendation |
|------|----------------|
| `node_modules` | 저장소 제외 권장 |
| `__MACOSX` | 삭제 권장 |
| `.DS_Store` | 삭제 권장 |
| `src/Console /ConsoleAction.js` | 중복/오타성 폴더 확인 필요 |
| `src/Storage/StorageAction.js` | 사용하지 않으면 제거 고려 |

---

## Recommended Wiki Reading Order

1. [[Overview]]
2. [[Architecture]]
3. [[Bridge Design]]
4. [[Communication Protocol]]
5. [[iOS Implementation]]
6. [[Web Implementation]]
7. [[Troubleshooting]]

---

## Summary

이 프로젝트는 iOS `WKWebView` 환경에서 동작하는  
브릿지 테스트용 Web 모듈로서 다음 가치가 있다.

- Native 기능 테스트 UI 제공
- Promise 기반 브릿지 요청 구조 구현
- 요청/응답 로그 가시화
- Web ↔ Native 통신 검증 환경 제공

즉, 단순한 웹 화면이 아니라  
**iOS 브릿지 통합 테스트를 위한 실험/검증용 인터페이스**라는 점에 의미가 있다.
