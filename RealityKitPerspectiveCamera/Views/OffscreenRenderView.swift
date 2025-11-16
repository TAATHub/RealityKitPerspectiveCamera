import SwiftUI
import RealityKit

struct OffscreenRenderView: View {
    @Environment(AppModel.self) private var appModel
    
    @State private var timer: Timer?
    @State private var rootEntity: Entity = .init()
    
    var body: some View {
        ZStack {
            RealityView { content in
                content.add(rootEntity)
            }
        }
        .onChange(of: appModel.renderTextureScene?.textureResources, { oldValue, newValue in
            guard let textureResource = newValue?.first else { return }
            let renderTextureMaterial = UnlitMaterial(texture: textureResource)
            let entity = ModelEntity(mesh: .generatePlane(width: 1.6, height: 0.9), materials: [renderTextureMaterial])
            entity.scale *= 0.3
            entity.position = [0, 0, -0.1]

            rootEntity.children.removeAll()
            rootEntity.addChild(entity)
        })
        .onChange(of: appModel.immersiveSpaceState, { _, state in
            switch state {
            case .open:
                // FIXME: Use System to update renderer instead of Timer
                timer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { _ in
                    Task { @MainActor in
                        guard let renderTextureScene = appModel.renderTextureScene,
                              let camera = renderTextureScene.cameras.first,
                              let transform = appModel.cameraTransform else { return }

                        camera.position = transform.translation
                        camera.orientation = transform.rotation * simd_quatf(angle: -.pi, axis: .init(x: 0, y: 1, z: 0))
                        try renderTextureScene.render()
                    }
                }
            case .closed:
                // Invalidate timer when immersive space is closed
                timer?.invalidate()
            default:
                break
            }
        })
    }
}

#Preview(windowStyle: .automatic) {
    OffscreenRenderView()
        .environment(AppModel.shared)
}
