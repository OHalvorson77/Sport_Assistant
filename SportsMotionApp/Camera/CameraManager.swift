import AVFoundation
import UIKit

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = CameraManager()

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var overlayView: PoseOverlayView?

    func setupPreview(in view: UIView, overlay: PoseOverlayView) {
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        self.previewLayer = preview

        overlay.frame = view.bounds
        overlay.backgroundColor = .clear
        view.addSubview(overlay)
        self.overlayView = overlay

        session.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let previewSize = previewLayer?.bounds.size else { return }

        PoseAnalyzer.shared.process(sampleBuffer: sampleBuffer, in: previewSize)
    }
}
