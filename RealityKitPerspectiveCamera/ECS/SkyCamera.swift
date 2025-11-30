import RealityKit

struct SkyCameraComponent: Component {
    var initialPosition: SIMD3<Float>
    
    init(position: SIMD3<Float> = .zero) {
        self.initialPosition = position
        SkyCameraSystem.registerSystem()
    }
}

final class SkyCameraSystem: System {
    private let query = EntityQuery(where: .has(SkyCameraComponent.self))
    
    private var deltaTime = 0.0
    private var angle: Double {
        deltaTime * 0.1
    }
    
    private let radius: Double = 5.0
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        deltaTime += context.deltaTime
        
        let entities = context.entities(matching: query, updatingSystemWhen: .rendering)
        for entity in entities {
            guard let component = entity.components[SkyCameraComponent.self] else { continue }
            
            let x = cos(angle) * radius + Double(component.initialPosition.x)
            let y = component.initialPosition.y
            let z = sin(angle) * radius + Double(component.initialPosition.z)
            entity.transform.translation = .init(Float(x), Float(y), Float(z))

            entity.look(at: component.initialPosition + .init(0, -3, 0), from: entity.transform.translation, relativeTo: nil)
            
            AppModel.shared.renderCameras[.camera1] = entity.transform
            updateSkyCameraEntity(name: entity.name, translation: entity.transform.translation, rotation: entity.transform.rotation)
        }
    }
    
    @MainActor
    private func updateSkyCameraEntity(name: String, translation: SIMD3<Float>, rotation: simd_quatf) {
        guard let scene = AppModel.shared.renderTextureScene else { return }
        for entity in scene.entities {
            if let skyCamera = entity.findEntity(named: name) {
                skyCamera.transform.translation = translation
                skyCamera.transform.rotation = rotation                
            }
        }
    }
}
