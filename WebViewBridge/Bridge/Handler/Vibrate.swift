import Foundation
import CoreHaptics

final class NativeHapticComboHandler: BridgeHandler {

    static let action = "native.haptic.vibrate"

    private var engine: CHHapticEngine?
    private var isPlaying = false

    init() {
        prepareEngine()
    }

    func handle(_ message: BridgeMessage, context: BridgeContext) {
        // payload로 길이/피크 조절도 가능
        let duration = (message.payload["duration"] as? Double) ?? 1.8
        let peak = (message.payload["peak"] as? Double) ?? 1.0
        playCombo(duration: duration, peak: Float(peak))
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Haptics not supported")
            return
        }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error:", error)
        }
    }

    private func playCombo(duration: TimeInterval, peak: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        guard let engine else { return }
        guard !isPlaying else { return }
        isPlaying = true

        let total = max(0.4, min(3.0, duration))

        // ✅ 강한 바닥 + 또렷한 느낌
        let baseIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35)
        let baseSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.85)

        let continuous = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [baseIntensity, baseSharpness],
            relativeTime: 0,
            duration: total
        )

        // ✅ 전체 커브 자체를 위로 끌어올림
        let points: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.00, value: 0.35),
            .init(relativeTime: total * 0.15, value: 0.55),
            .init(relativeTime: total * 0.30, value: 0.80),
            .init(relativeTime: total * 0.50, value: 1.00),
            .init(relativeTime: total * 0.70, value: 0.80),
            .init(relativeTime: total * 0.85, value: 0.55),
            .init(relativeTime: total * 1.00, value: 0.35),
        ]
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: points,
            relativeTime: 0
        )

        // ✅ sharpness도 높게 유지하면 손에 “빡” 느껴짐
        let sharpPoints: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.00, value: 0.80),
            .init(relativeTime: total * 0.50, value: 1.00),
            .init(relativeTime: total * 1.00, value: 0.80),
        ]
        let sharpCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: sharpPoints,
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [continuous], parameterCurves: [intensityCurve, sharpCurve])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            try player.start(atTime: 0)

            DispatchQueue.main.asyncAfter(deadline: .now() + total + 0.05) { [weak self] in
                self?.isPlaying = false
            }
        } catch {
            print("Haptic pattern error:", error)
            isPlaying = false
        }
    }
}
