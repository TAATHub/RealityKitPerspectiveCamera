import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    @State private var model: OffscreenRenderModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = []
    
    private var timer: AsyncStream<Void> {
        AsyncStream {
            try? await Task.sleep(for: .seconds(1/30))
        }
    }

    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 40) {
                VStack(spacing: 0) {
                    ControllerButton(imageName: "arrowtriangle.up.fill") {
                        appModel.controlParameter.forward = $0 ? 1 : 0
                    }
                    
                    HStack(spacing: 0) {
                        ControllerButton(imageName: "arrowtriangle.left.fill") {
                            appModel.controlParameter.rotation = $0 ? 1 : 0
                        }
                        
                        Spacer()
                        
                        ControllerButton(imageName: "arrowtriangle.right.fill") {
                            appModel.controlParameter.rotation = $0 ? -1 : 0
                        }
                    }
                    
                    ControllerButton(imageName: "arrowtriangle.down.fill") {
                        appModel.controlParameter.forward = $0 ? -1 : 0
                    }
                }
                .frame(width: 192)
                
                offscreenRenderView()
                    .aspectRatio(16/9, contentMode: .fit)
                
                VStack(spacing: 40) {
                    ControllerButton(imageName: "arrowtriangle.up.fill") {
                        appModel.controlParameter.up = $0 ? 1 : 0
                    }
                    
                    ControllerButton(imageName: "arrowtriangle.down.fill") {
                        appModel.controlParameter.up = $0 ? -1 : 0
                    }
                }
                .frame(width: 192)
            }
            
            ToggleImmersiveSpaceButton {
                tasks.forEach { task in
                    task.cancel()
                }
            }
        }
        .padding(40)
        .frame(width: 1200, height: 600)
    }
    
    private func offscreenRenderView() -> some View {
        GeometryReader { geometry in
            if let cgImage = model.renderTexture?.cgImage {
                Image(cgImage, scale: 1.0, label: Text("Render Texture"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Color.black
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .onChange(of: appModel.scene, { oldValue, newValue in
            guard let scene = newValue else { return }
            
            do {
                try model.setup(scene: scene)
                
                let timerTask = Task {
                    await withTaskGroup(of: Void.self) { group in
                        for await _ in timer {
                            group.addTask { @MainActor in
                                guard let transform = appModel.cameraTransform else { return }
                                try? model.render(position: transform.translation,
                                                  orientation: transform.rotation * simd_quatf(angle: -.pi, axis: .init(x: 0, y: 1, z: 0)))
                            }
                        }
                    }
                }
                tasks.insert(timerTask)
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
