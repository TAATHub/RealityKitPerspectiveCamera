import SwiftUI
import RealityKit
import RealityKitContent

enum SampleSceneType {
    case singleCamera
    case multiCameras
}

struct SampleImmersiveView: View {
    @State private var renderTextureScene: RenderTextureScene?
    
    // Change this property to switch between single camera and multi cameras sample scenes
    private let type: SampleSceneType = .singleCamera
    
    var body: some View {
        RealityView { content in
            do {
                let scene = try await load(type: type)
                content.add(scene)

                try await setupRenderer(type: type, scene: scene)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    private func load(type: SampleSceneType) async throws -> Entity {
        let name = switch type {
            case .singleCamera: "SampleScene_SingleCamera"
            case .multiCameras: "SampleScene_MultiCameras"
        }
        return try await Entity(named: name, in: realityKitContentBundle)
    }
    
    private func setupRenderer(type: SampleSceneType, scene: Entity) async throws {
        switch type {
            case .singleCamera:
                try await setupRendererForSingleCamera(scene: scene)
            case .multiCameras:
                try await setupRendererForMultiCameras(scene: scene)
        }
    }
    
    private func setupRendererForSingleCamera(scene: Entity) async throws {
        let clonedScene = scene.clone(recursive: true)
        
        if let entity = clonedScene.findEntity(named: "_Robot") {
            entity.removeFromParent()
        }
        
        // Setup
        let renderer = try RealityRenderer()
        renderer.entities.append(clonedScene)
        
        let camera = PerspectiveCamera()
        renderer.activeCamera = camera
        renderer.entities.append(camera)
        
        let descriptor = LowLevelTexture.Descriptor(pixelFormat: .bgra8Unorm, width: 1600, height: 900, textureUsage: [.renderTarget])
        let texture = try LowLevelTexture(descriptor: descriptor)
        let cameraOutput = try RealityRenderer.CameraOutput(.singleProjection(colorTexture: texture.read()))
        
        // Render
        if let cameraEntity = scene.findEntity(named: "Camera_1") {
            camera.position = cameraEntity.position
            camera.orientation = cameraEntity.orientation .reversed()
        }
        renderer.activeCamera = camera
        try renderer.updateAndRender(deltaTime: 0, cameraOutput: cameraOutput)
        
        // Display
        let textureResource = try await TextureResource(from: texture)
        let renderTextureMaterial = UnlitMaterial(texture: textureResource)
        let entity = ModelEntity(mesh: .generatePlane(width: 1.6, height: 0.9), materials: [renderTextureMaterial])
        entity.position = [0, 2, 0]
        scene.addChild(entity)
    }

    private func setupRendererForMultiCameras(scene: Entity) async throws {
        // Setup
        guard let renderTextureScene = try? RenderTextureScene(cameraAndTextures: [.init(width: 1600, height: 900), .init(width: 1600, height: 900)]) else { return }
        self.renderTextureScene = renderTextureScene
        
        renderTextureScene.entities.append(scene.clone(recursive: true))

        // Render
        for (index, camera) in renderTextureScene.cameras.enumerated() {
            if let cameraEntity = scene.findEntity(named: "Camera_\(index + 1)") {
                camera.position = cameraEntity.position
                camera.orientation = cameraEntity.orientation .reversed()
            }
        }
        
        try renderTextureScene.render()
        
        // Display
        let planePositions: [SIMD3<Float>] = [[-0.9, 2, 0], [0.9, 2, 0]]
        for (index, textureResource) in renderTextureScene.textureResources.enumerated() {
            let renderTextureMaterial = UnlitMaterial(texture: textureResource)
            let entity = ModelEntity(mesh: .generatePlane(width: 1.6, height: 0.9), materials: [renderTextureMaterial])
            entity.position = planePositions[index]
            scene.addChild(entity)
        }
    }
}
