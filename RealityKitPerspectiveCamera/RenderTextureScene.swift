import Foundation
import RealityKit

///
/// ```swift
/// renderTextureScene.entities.append(rootEntity.clone(recursive: true))
/// let renderTextureMaterial = UnlitMaterial(texture: renderTextureScene.textureResources[0])
/// ModelEntity(mesh: .generatePlane(width: 1, height: 1), materials: [renderTextureMaterial])
/// ...
///
/// do {
///     let camera = renderTextureScene.cameras[0]
///     camera.position = .init(0, 0.6, -1)
///     camera.orientation = .init(from: [0,0,1], to: [0, 0, -1])
///     try renderTextureScene.render()
/// } catch {
///     NSLog("%@", "realityRenderer.updateAndRender: error = \(String(describing: error))")
/// }
/// ```
///
/// Also see [https://gist.github.com/banjun/a6276dc0ec0cdf899dda41e55acca41c](https://gist.github.com/banjun/a6276dc0ec0cdf899dda41e55acca41c)
@MainActor final class RenderTextureScene: Sendable {
    let renderer: RealityRenderer = try! .init()
    var entities: RealityRenderer.EntityCollection {
        get {renderer.entities}
        set {renderer.entities = newValue}
    }
    var activeCamera: Entity? {
        get {renderer.activeCamera}
        set {renderer.activeCamera = newValue}
    }
    var cameraAndTextures: [CameraAndTexture] {
        didSet {
            oldValue.forEach {$0.camera.removeFromParent()}
            entities.append(contentsOf: cameras)
        }
    }
    var cameras: [PerspectiveCamera] {cameraAndTextures.map(\.camera)}
    var cameraOutputs: [RealityRenderer.CameraOutput] {cameraAndTextures.map(\.cameraOutput)}
    var textures: [LowLevelTexture] {cameraAndTextures.map(\.texture)}
    var textureResources: [TextureResource] {cameraAndTextures.map(\.textureResource)}

    @MainActor struct CameraAndTexture: Sendable {
        let camera: PerspectiveCamera
        let cameraOutput: RealityRenderer.CameraOutput
        let texture: LowLevelTexture
        let textureResource: TextureResource

        struct Descriptor: Sendable {
            var camera: PerspectiveCamera
            var width: Int
            var height: Int
            @MainActor init(camera: PerspectiveCamera? = nil, width: Int = 512, height: Int = 512) {
                self.camera = camera ?? .init()
                self.width = width
                self.height = height
            }
        }

        init(_ descriptor: Descriptor) throws {
            self.camera = descriptor.camera
            self.texture = try .init(descriptor: .init(pixelFormat: .bgra8Unorm, width: descriptor.width, height: descriptor.height, textureUsage: [.renderTarget]))
            self.textureResource = try .init(from: texture)
            self.cameraOutput = try .init(.singleProjection(colorTexture: texture.read()))
        }
    }

    init(cameraAndTextures: [CameraAndTexture.Descriptor]? = nil) throws {
        let cameraAndTextures = cameraAndTextures ?? [.init()]
        self.cameraAndTextures = try cameraAndTextures.map {try .init($0)}
        self.entities.append(contentsOf: cameras)
    }

    func render(deltaTime: TimeInterval = 0) throws {
        try cameraAndTextures.forEach {
            renderer.activeCamera = $0.camera
            try renderer.updateAndRender(deltaTime: deltaTime, cameraOutput: $0.cameraOutput) {_ in}
            // NOTE: on Simulator, this error might occur.
            // workaround 1: Use Physical Device
            // workaround 2: Disable Metal API Validation for the sceme, but it sometimes might output magenta texture
            // -[MTLDebugRenderCommandEncoder validateCommonDrawErrors:]:5782: failed assertion `Draw Errors Validation
            // Fragment Function(fsRealityPbr): the offset into the buffer lightConstants that is bound at buffer index 4 must be a multiple of 256 but was set to 78144.
        }
    }
}
