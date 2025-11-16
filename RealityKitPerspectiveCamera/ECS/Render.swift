import RealityKit

struct RenderTextureComponent: Component {
    init () {
        RenderTextureSystem.registerSystem()
    }
}

final class RenderTextureSystem: System {
    private let query = EntityQuery(where: .has(RenderTextureComponent.self))

    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: query, updatingSystemWhen: .rendering)
        for _ in entities {
            Task { @MainActor in
                render()
            }
        }
    }
    
    @MainActor
    private func render() {
        guard let renderTextureScene = AppModel.shared.renderTextureScene else { return }
        for (index, camera) in renderTextureScene.cameras.enumerated() {
            switch index {
            case 0:
                if let transform = AppModel.shared.droneCameraTransform {
                    camera.position = transform.translation
                    camera.orientation = transform.rotation * simd_quatf(angle: -.pi, axis: .init(x: 0, y: 1, z: 0))
                }
            case 1:
                camera.position = AppModel.shared.skyCameraTransform.translation
                camera.orientation = AppModel.shared.skyCameraTransform.rotation
            default:
                break
            }
        }
        
        try? renderTextureScene.render()
    }
}
