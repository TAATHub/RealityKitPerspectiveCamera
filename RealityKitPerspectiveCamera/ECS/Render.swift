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
            // TODO: Change index to an enum for better readability
            switch index {
            case 0:
                camera.transform = AppModel.shared.droneCameraTransform
            case 1:
                camera.transform = AppModel.shared.skyCameraTransform
            default:
                break
            }
        }
        
        try? renderTextureScene.render()
    }
}
