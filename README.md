# RealityKit Perspective Camera

A visionOS sample app demonstrating how to render perspective camera views from RealityKit scenes onto SwiftUI 2D windows using `RealityRenderer`.

## Demo

https://github.com/user-attachments/assets/e4986f5e-867d-4d92-a8c8-2e57750048a1

https://drive.google.com/file/d/1EdUHdmkRp1DnypYXEF7APBkaLsBNQJz-/view?usp=sharing

## Features

- **Multiple Camera Rendering**: Renders views from multiple perspective cameras simultaneously
  - Drone camera (first-person view from a controllable drone)
  - Sky camera (orbiting aerial view)
  - Fixed camera
- **Real-time Offscreen Rendering**: Uses `RealityRenderer` to render 3D scenes to textures displayed in 2D windows
- **Drone Control System**: Interactive drone controls for navigation (forward/backward, rotation, up/down)
- **ECS Architecture**: Implements Entity Component System pattern with custom components and systems
- **Crystal Collection Game**: Simple gameplay where you collect crystals with the drone

## Project Structure

```
RealityKitPerspectiveCamera/
├── RealityKitPerspectiveCameraApp.swift  # App entry point
├── RenderTextureScene.swift              # Core rendering logic using RealityRenderer
├── ECS/
│   ├── DroneControl.swift                # Drone movement component and system
│   ├── SkyCamera.swift                   # Orbiting camera component and system
│   └── Render.swift                      # Render texture update system
├── Views/
│   ├── ContentView.swift                 # Main UI with controller buttons
│   ├── ImmersiveView.swift               # Full immersive space setup
│   ├── SampleImmersiveView.swift         # Sample immersive space for testing
│   ├── OffscreenRenderView.swift         # Displays rendered camera textures
│   ├── ControllerButton.swift            # Reusable controller button
│   └── ToggleImmersiveSpaceButton.swift  # Immersive space toggle
├── Models/
│   └── AppModel.swift                    # Shared app state
├── Data/
│   └── ControlParameter.swift            # Control input parameters
├── Extensions/
│   ├── Entity+Extension.swift            # Entity helper extensions
│   ├── SIMD+Extension.swift              # SIMD math extensions
│   └── MTLTexture+Extension.swift        # Metal texture extensions
└── Packages/
    └── RealityKitContent/                # Reality Composer Pro scenes and assets
```

## Technical Highlights

### RealityRenderer for Offscreen Rendering

The app uses `RealityRenderer` to render scenes from perspective cameras to `LowLevelTexture`, which are then converted to `TextureResource` for display in SwiftUI views.

```swift
let renderer: RealityRenderer = try! .init()
let texture = try LowLevelTexture(descriptor: .init(
    pixelFormat: .bgra8Unorm,
    width: 512,
    height: 512,
    textureUsage: [.renderTarget]
))
let textureResource = try TextureResource(from: texture)
```

### Entity Component System

Custom ECS components and systems handle:
- **DroneControlComponent / DroneControlSystem**: Processes user input to move and rotate the drone
- **SkyCameraComponent / SkyCameraSystem**: Animates an orbiting camera around a fixed point
- **RenderTextureComponent / RenderTextureSystem**: Updates camera transforms and triggers rendering each frame

## Requirements

- visionOS 2.0+
- Xcode 16.0+
- Apple Vision Pro (device or simulator)

## Getting Started

1. Clone the repository
2. Open `RealityKitPerspectiveCamera.xcodeproj` in Xcode
3. Select a visionOS simulator or connected Apple Vision Pro device
4. Build and run the project

## Notes

- **Simulator Limitations**: On the visionOS Simulator, you may encounter Metal validation errors related to buffer alignment.
  - **Recommended**: Run on a physical Apple Vision Pro device
  - **Alternative**: Disable Metal API Validation in the scheme settings (may result in magenta-colored textures)
- The app runs in full immersion mode with a skybox environment.

## References

- [RealityRenderer - Apple Developer Documentation](https://developer.apple.com/documentation/realitykit/realityrenderer)
- [LowLevelTexture - Apple Developer Documentation](https://developer.apple.com/documentation/realitykit/lowleveltexture)
- [banjun's RealityRenderer gist](https://gist.github.com/banjun/a6276dc0ec0cdf899dda41e55acca41c)

## License

This project is available for educational and reference purposes.
