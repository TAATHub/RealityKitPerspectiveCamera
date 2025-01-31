import RealityKit

struct CameraComponent: Component {
    init () {
        CameraSystem.registerSystem()
    }
}

final class CameraSystem: System
{
    let query = EntityQuery(where: .has(CameraComponent.self))
    
    private var deltaTime = 0.0
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        deltaTime += context.deltaTime
        
        let entities = context.entities(matching: query, updatingSystemWhen: .rendering)
        for entity in entities {
            entity.transform.translation = .init(cos(Float(deltaTime * 0.5)), 0.5, -1.0)
            AppModel.shared.cameraTransform = entity.transform
        }
    }
}
