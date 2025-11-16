import RealityKit

struct DroneControlComponent: Component {
    init () {
        DroneControlSystem.registerSystem()
    }
}

final class DroneControlSystem: System {
    private let query = EntityQuery(where: .has(DroneControlComponent.self))
    private let speed = 1.0
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: query, updatingSystemWhen: .rendering)
        for entity in entities {
            var rotation = entity.transform.rotation
            rotation *= simd_quatf(angle: Float(AppModel.shared.controlParameter.rotation * context.deltaTime * speed),
                                   axis: .init(x: 0, y: 1, z: 0))
            entity.transform.rotation = rotation

            let localTranslation = SIMD3(x: 0,
                                    y: Float(AppModel.shared.controlParameter.up * context.deltaTime * speed),
                                    z: Float(AppModel.shared.controlParameter.forward * context.deltaTime * speed))
            let translation = entity.transform.matrix * SIMD4(localTranslation, 0)
            entity.transform.translation += translation.xyz
            
            AppModel.shared.droneCameraTransform = entity.transform            
            updateDroneEntity(translation: entity.transform.translation, rotation: entity.transform.rotation)
        }
    }
    
    @MainActor
    private func updateDroneEntity(translation: SIMD3<Float>, rotation: simd_quatf) {
        guard let scene = AppModel.shared.renderTextureScene else { return }
        for entity in scene.entities {
            if let drone = entity.findEntity(named: "Drone") {
                drone.transform.translation = translation
                drone.transform.rotation = rotation
            }
        }
    }
}
