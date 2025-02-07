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
    var renderTexture: MTLTexture?
    
    private var renderer: RealityRenderer?
    private var colorTexture: MTLTexture?
        
    func setup(scene: Entity) throws {
        renderer = try RealityRenderer()
        
        guard let renderer else { return }
        
        // If not clone entities in the scene, all entities in the immersive space will disapper when init this model.
        // Not sure how to avoid this.
        renderer.entities.append(scene.clone(recursive: true))
        
        let camera = PerspectiveCamera()
        renderer.activeCamera = camera
        renderer.entities.append(camera)
        
        let textureDesc = MTLTextureDescriptor()
        textureDesc.pixelFormat = .bgra8Unorm
        textureDesc.width = 1600
        textureDesc.height = 900
        textureDesc.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        let device = MTLCreateSystemDefaultDevice()!
        colorTexture = device.makeTexture(descriptor: textureDesc)!
    }
    
    func render(position: SIMD3<Float>, orientation: simd_quatf) throws {
        guard let renderer, let colorTexture else { return }
        
        renderer.activeCamera?.setPosition(position, relativeTo: nil)
        renderer.activeCamera?.setOrientation(orientation, relativeTo: nil)
        
        let cameraOutputDesc = RealityRenderer.CameraOutput.Descriptor.singleProjection(colorTexture: colorTexture)
        
        let cameraOutput = try RealityRenderer.CameraOutput(cameraOutputDesc)

        try renderer.updateAndRender(deltaTime: 0.1, cameraOutput: cameraOutput, onComplete: { [weak self] renderer in
            
            guard let colorTexture = cameraOutput.colorTextures.first else { fatalError() }
            self?.renderTexture = colorTexture
        })
    }
}
