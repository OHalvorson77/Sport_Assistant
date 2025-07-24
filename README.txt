# 🏃‍♂️ SportsMotionApp

**SportsMotionApp** is a real-time body movement tracking iOS app built in Swift using Vision and AVFoundation. It uses the device camera to detect body joints and provides **live spoken feedback** based on your motion — perfect for athletic training, workout correction, or form analysis in sports like tennis, basketball, golf, and more.

## 📸 Features

- 🧠 Real-time body pose detection using Vision Framework  
- 🔴 Visual joint tracking overlay on camera  
- 🎙️ Live voice feedback using AVSpeechSynthesizer  
- 🏀 Sport-specific logic (e.g., "Nice swing!", "Hold your form!", etc.)  
- 📱 Built using SwiftUI and UIKit interoperability

## 🛠 Requirements

- Xcode 15 or later  
- iOS 15.0+  
- Swift 5.7+  
- Physical iOS device (simulator doesn’t support camera)

## 📦 Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/SportsMotionApp.git
cd SportsMotionApp
2. Open the project in Xcode
bash
Copy
Edit
open SportsMotionApp.xcodeproj
3. Build and run on a real device
Pose detection requires camera access and will not work in the iOS simulator.

🔐 Permissions
Ensure the following permissions are included in your Info.plist:

xml
Copy
Edit
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to track your body movement for sports feedback.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app provides audio feedback based on your movement.</string>
🧩 Project Structure
graphql
Copy
Edit
SportsMotionApp/
├── CameraManager.swift          # Handles camera input (AVFoundation)
├── PoseAnalyzer.swift           # Runs Vision pose detection
├── PoseOverlayView.swift        # Draws red dots on joints
├── FeedbackManager.swift        # Converts motion into audio feedback
├── CameraView.swift             # SwiftUI bridge for UIKit camera
├── ContentView.swift            # Main SwiftUI layout (ZStack camera + overlay)
├── Assets.xcassets              # Assets and icon
└── Info.plist                   # Permission strings
🎮 How It Works
CameraManager initializes the camera and sends live video frames.

PoseAnalyzer processes each frame with Vision to detect body joints.

Detected joints are visualized via PoseOverlayView (red dots).

FeedbackManager evaluates joint movement patterns (e.g., arm swing).

It triggers real-time spoken feedback using AVSpeechSynthesizer.

🏋️‍♂️ Example Supported Sports Logic
You can customize sport-specific feedback inside FeedbackManager.swift.

Examples:

🏀 Basketball: Detects arm raise and gives "Great shot!" feedback

🎾 Tennis: Detects forehand swing and says "Nice swing!"

🏌️ Golf: Detects full body rotation and says "Good follow-through!"

🧘 Yoga: Detects steady poses and says "Hold that pose!"

🧠 Basic Tech Stack
Swift + SwiftUI — UI and architecture

AVFoundation — Camera access

Vision — Body pose detection (VNHumanBodyPoseRequest)

UIKit Overlay — Drawing joints using PoseOverlayView

AVSpeechSynthesizer — Live voice feedback

🚧 Future Features
 Draw skeleton lines between joints

 Add rep counting and motion classification

 Save session history

 Support Vision Pro / spatial feedback

 Machine learning model for improved detection

🙌 Credits
Built with ❤️ by Owen Halvorson
Powered by Apple Vision & AVFoundation APIs

📄 License
This project is licensed under the MIT License.
Feel free to use and modify it, but credit is appreciated.