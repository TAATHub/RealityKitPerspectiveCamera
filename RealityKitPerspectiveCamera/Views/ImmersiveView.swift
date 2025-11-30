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

                await setupRenderTextureScene(scene: scene)
                setupCameras(scene: scene)
                
                if let drone = await setupDrone() {
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
    
    private func setupCameras(scene: Entity) {
        if let camera1 = scene.findEntity(named: "Camera_1") {
            camera1.components.set(SkyCameraComponent(position: camera1.position))
        }
        
        if let camera2 = scene.findEntity(named: "Camera_2") {
            appModel.renderCameras[.camera2] = camera2.transform
        }
    }
    
    private func setupRenderTextureScene(scene: Entity) async {
        guard let renderTextureScene = try? RenderTextureScene(cameraAndTextures: [RenderCameraType.droneCamera.descriptor,
                                                                                   RenderCameraType.camera1.descriptor,
                                                                                   RenderCameraType.camera2.descriptor]) else { return }
        let clonedScene = scene.clone(recursive: true)
        
        if let drone = await setupDrone(withComponents: false) {
            clonedScene.addChild(drone)
        }
        
        renderTextureScene.entities.append(clonedScene)
        appModel.renderTextureScene = renderTextureScene
    }
    
    private func setupDrone(withComponents: Bool = true) async -> Entity? {
        guard let drone = try? await Entity(named: "Drone", in: realityKitContentBundle) else { return nil }
        drone.name = "Drone"
        drone.position = [0, 1, -4]
        drone.orientation = .init(angle: Float.pi, axis: .init(x: 0, y: 1, z: 0))
        
        if withComponents {
            drone.components.set(DroneControlComponent())
            drone.components.set(CollisionComponent(shapes: [.generateBox(size: .init(repeating: 0.5))], mode: .trigger))
        }
        
        return drone
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
