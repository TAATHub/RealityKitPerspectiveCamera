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
            if let type = RenderCameraType(rawValue: index), let renderCamera = AppModel.shared.renderCameras[type] {
                camera.transform = renderCamera
            }
        }
        
        try? renderTextureScene.render()
    }
}
