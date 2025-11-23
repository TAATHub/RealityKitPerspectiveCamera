import RealityKit

struct DroneControlComponent: Component {
    init () {
        DroneControlSystem.registerSystem()
    }
}

final class DroneControlSystem: System {
    private let query = EntityQuery(where: .has(DroneControlComponent.self))
    private let moveSpeed = 5.0
    private let rotationSpeed = 2.0
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: query, updatingSystemWhen: .rendering)
        for entity in entities {
            var rotation = entity.transform.rotation
            rotation *= simd_quatf(angle: Float(AppModel.shared.controlParameter.rotation * context.deltaTime * rotationSpeed),
                                   axis: .init(x: 0, y: 1, z: 0))
            entity.transform.rotation = rotation

            let localTranslation = SIMD3(x: 0,
                                    y: Float(AppModel.shared.controlParameter.up * context.deltaTime * moveSpeed),
                                         z: Float(AppModel.shared.controlParameter.forward * context.deltaTime * moveSpeed))
            let translation = entity.transform.matrix * SIMD4(localTranslation, 0)
            entity.transform.translation += translation.xyz
            
            if let droneCamera = entity.findEntity(named: "DroneCamera") {
                AppModel.shared.droneCameraTransform.translation = droneCamera.position(relativeTo: nil)
                AppModel.shared.droneCameraTransform.rotation = entity.transform.rotation.reversed(around: .upward)
            }
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
