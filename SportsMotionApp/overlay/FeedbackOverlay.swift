import SwiftUI

struct FeedbackOverlay: View {
    var feedback: String

    var body: some View {
        VStack {
            Spacer()
            Text(feedback)
                .padding()
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
        }
    }
}
