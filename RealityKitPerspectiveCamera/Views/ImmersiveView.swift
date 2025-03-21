import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
                
                if let skybox = Entity.createSkybox(name: "Skybox") {
                    scene.addChild(skybox)
                }
                
                guard let env = try? await EnvironmentResource(named: "Sunlight") else { return }
                let iblComponent = ImageBasedLightComponent(source: .single(env), intensityExponent: 1.0)
                scene.components[ImageBasedLightComponent.self] = iblComponent
                scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
                
                appModel.scene = scene.clone(recursive: true)
                
                if let drone = try? await Entity(named: "Drone", in: realityKitContentBundle) {
                    drone.position = [0, 1, -1]
                    drone.orientation = .init(angle: Float.pi, axis: .init(x: 0, y: 1, z: 0))
                    drone.components.set(DroneControlComponent())
                    drone.components.set(CollisionComponent(shapes: [.generateBox(size: .init(0.2, 0.1, 0.2))]))
                    
                    var physicsBody = PhysicsBodyComponent(mode: .dynamic)
                    physicsBody.isAffectedByGravity = false
                    physicsBody.linearDamping = 0.1
                    physicsBody.massProperties.mass = 0.8
                    drone.components.set(physicsBody)
                    
                    if let animation = drone.availableAnimations.last {
                        drone.playAnimation(animation.repeat())
                    }
                    scene.addChild(drone)
                    
                    _ = content.subscribe(to: CollisionEvents.Began.self, on: drone, handleCollision(_:))
                }
            }
            
            appModel.crystalCount = 0
        }
    }
    
    private func handleCollision(_ event: CollisionEvents.Began)
    {
        event.entityB.removeFromParent()
        
        if let entity = appModel.scene?.findEntity(named: event.entityB.name) {
            entity.removeFromParent()
        }
        
        appModel.crystalCount += 1
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
