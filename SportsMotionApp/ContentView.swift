import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            CameraView()
            FeedbackOverlay(feedback: "Nice Shot!")
        }
        .edgesIgnoringSafeArea(.all)
    }
}
