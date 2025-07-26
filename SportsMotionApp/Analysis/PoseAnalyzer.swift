import Vision
import AVFoundation

class PoseAnalyzer {
    static let shared = PoseAnalyzer()

    var onPoseDetected: (([VNHumanBodyPoseObservation.JointName: CGPoint]) -> Void)?

    func process(sampleBuffer: CMSampleBuffer, in size: CGSize) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        try? handler.perform([request])
        guard let observations = request.results else { return }

        for observation in observations {
            guard let recognizedPoints = try? observation.recognizedPoints(.all) else { continue }

            var displayPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]

            for (jointName, point) in recognizedPoints {
                guard point.confidence > 0.3 else { continue }

                let convertedPoint = CGPoint(
                    x: point.location.x * size.width,
                    y: (1 - point.location.y) * size.height // flip Y-axis
                )
                displayPoints[jointName] = convertedPoint
            }

            DispatchQueue.main.async {
                self.onPoseDetected?(displayPoints)
                FeedbackManager.shared.process(joints: displayPoints)
            }
        }
    }

}
