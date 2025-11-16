import RealityKit

struct SkyCameraComponent: Component {
    init () {
        SkyCameraSystem.registerSystem()
    }
}

final class SkyCameraSystem: System {
    private let query = EntityQuery(where: .has(SkyCameraComponent.self))
    
    private var deltaTime = 0.0
    private var angle: Double {
        deltaTime * 0.1
    }
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        deltaTime += context.deltaTime
        
        let entities = context.entities(matching: query, updatingSystemWhen: .rendering)
        for entity in entities {
            let x = cos(angle) * 5
            let y = 3.0
            let z = sin(angle) * 5 - 20
            entity.transform.translation = .init(Float(x), Float(y), Float(z))
            
//            let yaw = simd_quatf(angle: -Float(angle), axis: .upward)
//            let roll = simd_quatf(angle: -.pi/6, axis: .forward)
//            let pitch = simd_quatf(angle: .pi/6, axis: .right)
//            entity.transform.rotation = yaw * pitch
            entity.look(at: .init(0, 2.5, -20), from: entity.transform.translation, relativeTo: nil)
            
            AppModel.shared.skyCameraTransform = entity.transform
        }
    }
}
