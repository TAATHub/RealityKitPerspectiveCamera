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
                
                let skyCameraEntity = Entity()
                skyCameraEntity.components.set(SkyCameraComponent())
                scene.addChild(skyCameraEntity)

                if let renderTextureScene = try? RenderTextureScene(cameraAndTextures: [.init(width: 1600, height: 900), .init(width: 1600, height: 900)]) {
                    let clonedScene = scene.clone(recursive: true)
                    
                    if let drone = try? await Entity(named: "Drone", in: realityKitContentBundle) {
                        drone.name = "Drone"
                        drone.position = [0, 1, -1]
                        drone.orientation = .init(angle: Float.pi, axis: .init(x: 0, y: 1, z: 0))
                        if let animation = drone.availableAnimations.last {
                            drone.playAnimation(animation.repeat())
                        }
                        clonedScene.addChild(drone)
                    }
                    
                    renderTextureScene.entities.append(clonedScene)
                    appModel.renderTextureScene = renderTextureScene
                }

                if let drone = try? await Entity(named: "Drone", in: realityKitContentBundle) {
                    drone.name = "Drone"
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
                
                let renderTextureEntity = Entity()
                renderTextureEntity.components.set(RenderTextureComponent())
                scene.addChild(renderTextureEntity)
            }
            
            appModel.crystalCount = 0
        }
    }
    
    private func handleCollision(_ event: CollisionEvents.Began)
    {
        event.entityB.removeFromParent()
        
        if let scene = appModel.renderTextureScene {
            for entity in scene.entities {
                if let target = entity.findEntity(named: event.entityB.name) {
                    target.removeFromParent()
                }
            }
        }
        
        appModel.crystalCount += 1
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel.shared)
}
