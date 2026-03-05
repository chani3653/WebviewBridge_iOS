import Foundation

enum LogDirection {
    case webToNative
    case nativeToWeb
}

enum LogStatus {
    case pending   // 일반 (진행 중)
    case success   // 성공
    case failure   // 실패
}

struct LogItem {
    let direction: LogDirection
    let status: LogStatus
    let action: String
    let detail: String
    let timestamp: Date
    
    init(direction: LogDirection, status: LogStatus, action: String, detail: String, timestamp: Date = Date()) {
        self.direction = direction
        self.status = status
        self.action = action
        self.detail = detail
        self.timestamp = timestamp
    }
    
    var directionText: String {
        switch direction {
        case .webToNative: return "W → N"
        case .nativeToWeb: return "N → W"
        }
    }
    
    var statusText: String {
        switch status {
        case .pending: return "대기"
        case .success: return "성공"
        case .failure: return "실패"
        }
    }
}
