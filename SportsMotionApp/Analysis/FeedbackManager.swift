import Foundation
import Vision
import AVFoundation

class FeedbackManager {
    static let shared = FeedbackManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var hasRecentlySpoken = false
    
    // Keeps track of recent joint frames to detect motion
    private var recentJoints: [[VNHumanBodyPoseObservation.JointName: CGPoint]] = []
    private let maxFrames = 5
    
    private let elevenLabsAPIKey = "sk_dc781e61da47f8f82e36fd1ece4e54374b5656c5f15e0c53"
    private let voiceID = "IZl7aMcWb3WnBsxQFo8H"
    
    private var player: AVAudioPlayer?

    
    private init() {}

    // Call this on every frame from PoseAnalyzer
    func process(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        updateRecentFrames(with: joints)
        
        guard recentJoints.count >= 2 else { return }
        
        if let improvement = generateFeedback(from: joints) {
            speak(improvement)
        }
    }
    
    private func speak(_ message: String) {
        generateSpeechWithElevenLabs(text: message)
    }
    
    private func generateFeedback(from joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> String? {
        guard let wrist = joints[.rightWrist],
              let elbow = joints[.rightElbow],
              let shoulder = joints[.rightShoulder],
              let hip = joints[.rightHip] else { return nil }

        var feedback = [String]()

        // Check elbow position (should be under the wrist)
        if elbow.x < wrist.x - 0.1 || elbow.x > wrist.x + 0.1 {
            feedback.append("Try to keep your elbow directly under your wrist.")
        }

        // Check wrist height (should be above shoulder at release)
        if wrist.y < shoulder.y {
            feedback.append("Raise your shooting hand higher.")
        }

        // Check arm extension (arm should be nearly straight)
        let armLength = distance(from: shoulder, to: wrist)
        let forearm = distance(from: elbow, to: wrist)
        if forearm / armLength > 0.8 {
            feedback.append("Extend your arm fully on the release.")
        }

        // Check posture: hip under shoulder
        if abs(hip.x - shoulder.x) > 0.2 {
            feedback.append("Keep your body more balanced and centered.")
        }

        return feedback.isEmpty ? nil : feedback.joined(separator: " ")
    }

    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return hypot(from.x - to.x, from.y - to.y)
    }

    private func updateRecentFrames(with joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        recentJoints.append(joints)
        if recentJoints.count > maxFrames {
            recentJoints.removeFirst()
        }
    }

    // Approximate logic to detect a basketball shot
    private func detectBasketballShot() -> Bool {
        guard
            let latest = recentJoints.last,
            let previous = recentJoints.dropLast().last,
            let wrist = latest[.rightWrist],
            let elbow = latest[.rightElbow],
            let shoulder = latest[.rightShoulder],
            let prevWrist = previous[.rightWrist]
        else { return false }

        let wristAboveShoulder = wrist.y > shoulder.y
        let elbowBelowWrist = elbow.y < wrist.y
        let armExtended = abs(wrist.y - elbow.y) > 0.15
        let wristMovingUp = wrist.y - prevWrist.y > 0.05

        return wristAboveShoulder && elbowBelowWrist && armExtended && wristMovingUp
    }
    
    private func generateSpeechWithElevenLabs(text: String) {
            guard let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceID)") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("audio/mpeg", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(elevenLabsAPIKey, forHTTPHeaderField: "xi-api-key")

            let body: [String: Any] = [
                "text": text,
                "model_id": "eleven_monolingual_v1", // or another model
                "voice_settings": [
                    "stability": 0.5,
                    "similarity_boost": 0.7
                ]
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("❌ Failed to fetch ElevenLabs audio: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    self.player = try AVAudioPlayer(data: data)
                    self.player?.prepareToPlay()
                    self.player?.play()
                } catch {
                    print("❌ Failed to play ElevenLabs audio: \(error.localizedDescription)")
                }
            }.resume()
        }
}
