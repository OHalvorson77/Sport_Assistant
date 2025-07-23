import UIKit
import Vision

class PoseOverlayView: UIView {
    private var bodyPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]

    func update(with points: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        self.bodyPoints = points
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setFillColor(UIColor.red.cgColor)
        context.setLineWidth(2.0)

        for (_, point) in bodyPoints {
            let dotRect = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
            context.fillEllipse(in: dotRect)
        }
    }
}
