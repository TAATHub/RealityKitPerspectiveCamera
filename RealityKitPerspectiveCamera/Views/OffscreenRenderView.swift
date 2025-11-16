import SwiftUI
import RealityKit

struct OffscreenRenderView: View {
    @Environment(AppModel.self) private var appModel
    @State private var rootEntity: Entity = .init()
    
    let positions: [SIMD3<Float>] = [[0, -0.085, 0.01], [0, 0.085, 0.01]]
    
    var body: some View {
        RealityView { content in
            content.add(rootEntity)
        }
        .frame(width: 400, height: 460)
        .frame(depth: 0.1)
        .onChange(of: appModel.renderTextureScene?.textureResources, { oldValue, newValue in
            guard let textureResources = newValue else { return }
            
            rootEntity.children.removeAll()
            
            for (index, textureResource) in textureResources.enumerated() {
                let renderTextureMaterial = UnlitMaterial(texture: textureResource)
                let entity = ModelEntity(mesh: .generatePlane(width: 1.6, height: 0.9), materials: [renderTextureMaterial])
                entity.scale *= 0.18
                entity.position = positions[index]
                rootEntity.addChild(entity)
            }
        })
    }
}

#Preview(windowStyle: .automatic) {
    OffscreenRenderView()
        .environment(AppModel.shared)
}
