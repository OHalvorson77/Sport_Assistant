import Vision
import AVFoundation

class PoseAnalyzer {
    static let shared = PoseAnalyzer()

    var onPoseDetected: (([VNHumanBodyPoseObservation.JointName: CGPoint]) -> Void)?

    func process(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        try? handler.perform([request])
        guard let observations = request.results else { return }

        for observation in observations {
            guard let recognizedPoints = try? observation.recognizedPoints(.all) else { continue }

            var displayPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]

            if let wrist = recognizedPoints[.rightWrist], wrist.confidence > 0.3 {
                displayPoints[.rightWrist] = wrist.location
            }

            // Call the callback on the main thread
            DispatchQueue.main.async {
                print("Sending points to overlay: \(displayPoints)")
                self.onPoseDetected?(displayPoints)
            }
        }
    }
}
