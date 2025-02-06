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

                appModel.scene = scene
                
                if let drone = try? await Entity(named: "Drone", in: realityKitContentBundle) {
                    drone.position = [0, 1, -1]
                    drone.orientation = .init(angle: Float.pi, axis: .init(x: 0, y: 1, z: 0))
                    drone.components.set(DroneControlComponent())
                    
                    if let animation = drone.availableAnimations.last {
                        drone.playAnimation(animation.repeat())
                    }
                    scene.addChild(drone)
                }
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
