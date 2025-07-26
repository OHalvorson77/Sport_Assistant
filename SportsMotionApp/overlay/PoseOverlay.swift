import UIKit
import Vision

class PoseOverlayView: UIView {
    private var jointPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]

    func update(with joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        self.jointPoints = joints
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setFillColor(UIColor.red.cgColor)
        context.setLineWidth(2)

        for (_, point) in jointPoints {
            let radius: CGFloat = 6.0
            let circleRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
            context.fillEllipse(in: circleRect)
        }
    }
}
