import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
                
                if let camera = scene.findEntity(named: "Camera") {
                    camera.components.set(CameraComponent())
                }
                
                guard let env = try? await EnvironmentResource(named: "Sunlight") else { return }
                let iblComponent = ImageBasedLightComponent(source: .single(env), intensityExponent: 1.0)
                scene.components[ImageBasedLightComponent.self] = iblComponent
                scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))

                appModel.scene = scene
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
