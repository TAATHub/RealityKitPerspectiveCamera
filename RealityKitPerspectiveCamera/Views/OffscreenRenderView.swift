import SwiftUI
import RealityKit

struct OffscreenRenderView: View {
    @Environment(AppModel.self) private var appModel
    
    @State private var model: OffscreenRenderModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = []
    
    @State private var texture: LowLevelTexture?
    private let commandQueue: MTLCommandQueue
    
    init() {
        let device = MTLCreateSystemDefaultDevice()!
        self.commandQueue = device.makeCommandQueue()!
    }
    
    private var timer: AsyncStream<Void> {
        AsyncStream {
            try? await Task.sleep(for: .seconds(1/30))
        }
    }
    
    var body: some View {
        RealityView { content in
            let entity = try! renderEntity()
            content.add(entity)
        }
        .onChange(of: appModel.immersiveSpaceState, { _, state in
            switch state {
            case .closed:
                tasks.forEach { task in
                    task.cancel()
                }
            default:
                break
            }
        })
        .onChange(of: appModel.scene, { oldValue, newValue in
            guard let scene = newValue else { return }
            
            do {
                try model.setup(scene: scene)
                
                let timerTask = Task {
                    await withTaskGroup(of: Void.self) { group in
                        for await _ in timer {
                            group.addTask { @MainActor in
                                guard let transform = appModel.cameraTransform else { return }
                                try? model.render(position: transform.translation,
                                                  orientation: transform.rotation * simd_quatf(angle: -.pi, axis: .init(x: 0, y: 1, z: 0)))
                                if let texture = model.renderTexture {
                                    updateTexture(with: texture)
                                }
                            }
                        }
                    }
                }
                tasks.insert(timerTask)
            } catch {
                // do nothing
            }
        })
    }
}

extension OffscreenRenderView {
    private var lowLevelTextureDescriptor: LowLevelTexture.Descriptor {
        var desc = LowLevelTexture.Descriptor()

        desc.textureType = .type2D
        desc.arrayLength = 1

        desc.width = 1600
        desc.height = 900
        desc.depth = 1

        desc.mipmapLevelCount = 1
        desc.pixelFormat = .bgra8Unorm
        desc.textureUsage = [.shaderRead, .shaderWrite]
        desc.swizzle = .init(red: .red, green: .green, blue: .blue, alpha: .alpha)

        return desc
    }
    
    private func renderEntity() throws -> Entity {
        let mesh = MeshResource.generatePlane(width: 1.6, height: 0.9)
        let texture = try LowLevelTexture(descriptor: lowLevelTextureDescriptor)
        let resource = try TextureResource(from: texture)
        
        var material = UnlitMaterial()
        material.color.texture = .init(resource)
        material.opacityThreshold = 0.5
        
        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        let entity = Entity()
        entity.components.set(modelComponent)
        entity.scale *= 0.3
        entity.position = [0, 0, -0.1]

        self.texture = texture
        return entity
    }
    
    private func updateTexture(with mtlTexture: MTLTexture) {
        guard let texture else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let blitEncoder = commandBuffer.makeBlitCommandEncoder()
        else { return }
        
        commandBuffer.enqueue()
        
        let outTexture: MTLTexture = texture.replace(using: commandBuffer)
        blitEncoder.copy(from: mtlTexture, to: outTexture)
        
        blitEncoder.endEncoding()
        commandBuffer.commit()
    }
}

#Preview(windowStyle: .automatic) {
    OffscreenRenderView()
        .environment(AppModel())
}
