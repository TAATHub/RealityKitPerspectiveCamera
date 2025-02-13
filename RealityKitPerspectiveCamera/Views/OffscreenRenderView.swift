import SwiftUI
import RealityKit

struct OffscreenRenderView: View {
    @Environment(AppModel.self) private var appModel
    
    @State private var model: OffscreenRenderModel = .init()
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            if model.isRendererUpdated {
                RealityView { content in
                    if let entity = try? renderEntity() {
                        content.add(entity)
                    }
                }
            } else {
                Color.black
            }
        }
        .onChange(of: appModel.immersiveSpaceState, { _, state in
            switch state {
            case .closed:
                // Invalidate timer when immersive space is closed
                timer?.invalidate()
            default:
                break
            }
        })
        .onChange(of: appModel.scene, { _, newValue in
            guard let scene = newValue else { return }
            
            do {
                try model.setup(scene: scene)
                
                timer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { _ in
                    Task { @MainActor in
                        guard let transform = appModel.cameraTransform else { return }
                        // Render with shared camera translation & rotation
                        try? model.render(position: transform.translation,
                                          orientation: transform.rotation * simd_quatf(angle: -.pi, axis: .init(x: 0, y: 1, z: 0)))
                    }
                }
            } catch {
                // do nothing
            }
        })
    }
}

// ref: https://gist.github.com/Matt54/c4d2ce778ffb6f9d2ddc6b8c7332c7d5
extension OffscreenRenderView {
    // Entity for rendering with LowLevelTexture
    private func renderEntity() throws -> Entity? {
        guard let lowLevelTexture = model.lowLevelTexture,
              let resource = try? TextureResource(from: lowLevelTexture) else { return nil }
        
        var material = UnlitMaterial()
        material.color.texture = .init(resource)
        
        let mesh = MeshResource.generatePlane(width: 1.6, height: 0.9)
        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        
        let entity = Entity()
        entity.components.set(modelComponent)
        entity.scale *= 0.3
        entity.position = [0, 0, -0.1]

        return entity
    }
}

#Preview(windowStyle: .automatic) {
    OffscreenRenderView()
        .environment(AppModel())
}
