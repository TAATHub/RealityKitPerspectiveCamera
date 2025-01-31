import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    @State var model: OffscreenRenderModel = .init()
    
    private let timer = AsyncStream {
        try? await Task.sleep(for: .seconds(0.01))
    }

    var body: some View {
        VStack(spacing: 40) {
            renderedView()
            ToggleImmersiveSpaceButton()
        }
        .padding(40)
        .frame(width: 800, height: 600)
    }
    
    private func renderedView() -> some View {
        GeometryReader { geometry in
            if let cgImage = model.renderTexture?.cgImage {
                Image(cgImage, scale: 1.0, label: Text("Render Texture"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                Color.black
            }
        }
        .onChange(of: appModel.scene, { oldValue, newValue in
            guard let scene = newValue else { return }
            
            do {
                try model.setup(scene: scene)
                
                Task {
                    await withTaskGroup(of: Void.self) { group in
                        for await _ in timer {
                            group.addTask { @MainActor in
                                guard let translation = appModel.cameraTransform?.translation else { return }
                                try? model.render(position: .init(x: translation.x, y: translation.y, z: translation.z - 0.1),
                                                  orientation: simd_quatf(angle: -.pi/6, axis: SIMD3<Float>(1, 0, 0)))
                            }
                        }
                    }
                }
            } catch {
                // do nothing
            }
        })
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
