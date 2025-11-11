import RealityKit

extension Entity {
    static func createSkybox(name: String) -> Entity? {
        let sphere = MeshResource.generateSphere(radius: 1000)
        var material = UnlitMaterial()
        
        do {
            let texture = try TextureResource.load(named: name)
            material.color = .init(texture: .init(texture))
            
            let entity = Entity()
            entity.components.set(ModelComponent(mesh: sphere, materials: [material]))
            entity.scale = .init(x: -1, y: 1, z: 1)
            return entity
        } catch {
            return nil
        }
    }
}
