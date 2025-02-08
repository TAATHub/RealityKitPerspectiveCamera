import Observation
import Metal
import RealityFoundation
import SwiftUI

/// Model for rendering given scene using RealityRenderer
///
/// - note: See [this thread](https://developer.apple.com/forums/thread/762238?answerId=801164022#801164022)
@Observable
@MainActor
final class OffscreenRenderModel {
    var lowLevelTexture: LowLevelTexture?
    
    private var renderer: RealityRenderer?
    private var commandQueue: MTLCommandQueue?
    private var colorTexture: MTLTexture?
    
    init() {
        lowLevelTexture = try? LowLevelTexture(descriptor: lowLevelTextureDescriptor)
        commandQueue = MTLCreateSystemDefaultDevice()?.makeCommandQueue()
    }
    
    var isRendererUpdated = false
        
    func setup(scene: Entity) throws {
        renderer = try RealityRenderer()
        guard let renderer else { return }
        
        // If not clone entities in the scene, all entities in the immersive space will disapper when init this model.
        // Discussing here: https://developer.apple.com/forums/thread/773957
        renderer.entities.append(scene.clone(recursive: true))
        
        let camera = PerspectiveCamera()
        renderer.activeCamera = camera
        renderer.entities.append(camera)
    }
    
    func render(position: SIMD3<Float>, orientation: simd_quatf) throws {
        guard let renderer,
              let commandBuffer = commandQueue?.makeCommandBuffer(),
              let colorTexture = lowLevelTexture?.replace(using: commandBuffer) else { return }
        
        renderer.activeCamera?.setPosition(position, relativeTo: nil)
        renderer.activeCamera?.setOrientation(orientation, relativeTo: nil)
        
        let cameraOutputDesc = RealityRenderer.CameraOutput.Descriptor.singleProjection(colorTexture: colorTexture)
        let cameraOutput = try RealityRenderer.CameraOutput(cameraOutputDesc)
        try renderer.updateAndRender(deltaTime: 0.1, cameraOutput: cameraOutput)
        
        if !isRendererUpdated {
            isRendererUpdated = true
        }
    }
    
    private var lowLevelTextureDescriptor: LowLevelTexture.Descriptor {
        var desc = LowLevelTexture.Descriptor()

        desc.textureType = .type2D
        desc.arrayLength = 1

        desc.width = 1600
        desc.height = 900
        desc.depth = 1

        desc.mipmapLevelCount = 1
        desc.pixelFormat = .bgra8Unorm
        desc.textureUsage = [.renderTarget]
        desc.swizzle = .init(red: .red, green: .green, blue: .blue, alpha: .alpha)

        return desc
    }
}
