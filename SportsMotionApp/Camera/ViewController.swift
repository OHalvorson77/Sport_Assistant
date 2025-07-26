import UIKit

class ViewController: UIViewController {
    private let overlayView = PoseOverlayView()

    override func viewDidLoad() {
        super.viewDidLoad()

        CameraManager.shared.setupPreview(in: view, overlay: overlayView)

        PoseAnalyzer.shared.onPoseDetected = { [weak self] joints in
            self?.overlayView.update(with: joints)
        }
    }
}
