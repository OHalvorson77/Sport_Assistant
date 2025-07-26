import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            CameraView() // shows live camera with overlay dots
            FeedbackOverlay(feedback: "Nice Shot!") // Optional UI on top
        }
        .edgesIgnoringSafeArea(.all)
    }
}
