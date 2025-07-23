import AVFoundation
import UIKit
import Vision

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = CameraManager()

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var overlayView: PoseOverlayView?


    func setupPreview(in view: UIView) {
            session.sessionPreset = .high

            // Setup input
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return }

            session.addInput(input)

            // Setup output
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            // Setup preview
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.frame = view.bounds
            previewLayer?.videoGravity = .resizeAspectFill

            if let layer = previewLayer {
                view.layer.addSublayer(layer)
            }
        
            let overlay = PoseOverlayView(frame: view.bounds)
            view.addSubview(overlay)
            overlay.backgroundColor = .clear
            self.overlayView = overlay

            session.startRunning()
        }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        try? handler.perform([request])
        guard let observations = request.results else { return }

        for observation in observations {
            guard let recognizedPoints = try? observation.recognizedPoints(.all) else { continue }

            // Filter only the points you want
            var displayPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]

            if let wrist = recognizedPoints[.rightWrist], wrist.confidence > 0.3 {
                let converted = VNImagePointForNormalizedPoint(wrist.location,
                                                               Int(previewLayer?.bounds.width ?? 1),
                                                               Int(previewLayer?.bounds.height ?? 1))
                displayPoints[.rightWrist] = CGPoint(x: converted.x, y: converted.y)
            }

            DispatchQueue.main.async {
                self.overlayView?.update(with: displayPoints)
            }
        }
    }
}
