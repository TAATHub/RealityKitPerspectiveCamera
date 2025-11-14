import Observation
import Metal
import RealityKit
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
    
    init() {
        lowLevelTexture = try? LowLevelTexture(descriptor: lowLevelTextureDescriptor)
        commandQueue = MTLCreateSystemDefaultDevice()?.makeCommandQueue()
    }
    
    var isRendererUpdated = false
        
    func setup(scene: Entity) throws {
        renderer = try RealityRenderer()
        guard let renderer else { return }
        
        // When the scene entity is added to RealityRenderer, it removes scene from the immersive space's content.
        // So we have to clone the scene entity recursively.
        // See this thread: https://developer.apple.com/forums/thread/773957
        renderer.entities.append(scene)
        
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
        
        // Pass the colorTexture replaced from lowLevelTexture directly to RealityRenderer.CameraOutput
        let cameraOutputDesc = RealityRenderer.CameraOutput.Descriptor.singleProjection(colorTexture: colorTexture)
        let cameraOutput = try RealityRenderer.CameraOutput(cameraOutputDesc)
        try renderer.updateAndRender(deltaTime: 0.1, cameraOutput: cameraOutput)
        
        if !isRendererUpdated {
            isRendererUpdated = true
        }
    }
    
    // Descriptor for LowLevelTexture
    private var lowLevelTextureDescriptor: LowLevelTexture.Descriptor {
        var desc = LowLevelTexture.Descriptor()

        desc.textureType = .type2D
        desc.arrayLength = 1

        desc.width = 1600
        desc.height = 900
        desc.depth = 1

        desc.mipmapLevelCount = 1
        desc.pixelFormat = .bgra8Unorm
        desc.textureUsage = [.renderTarget] // Set the usage for rendering
        desc.swizzle = .init(red: .red, green: .green, blue: .blue, alpha: .alpha)

        return desc
    }
}
