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
    
    static func createAxes(length: Float = 0.5, thickness: Float = 0.01) -> Entity {
        let axes = Entity()
        let origin = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [UnlitMaterial(color: .white)])
        
        let axisX = ModelEntity(mesh: .generateCylinder(height: length, radius: thickness), materials: [UnlitMaterial(color: .red)])
        axisX.position = [length / 2, 0, 0]
        axisX.orientation = simd_quatf(angle: .pi / 2, axis: [0, 0, 1])
        
        let axisY = ModelEntity(mesh: .generateCylinder(height: length, radius: thickness), materials: [UnlitMaterial(color: .green)])
        axisY.position = [0, length / 2, 0]
        
        let axisZ = ModelEntity(mesh: .generateCylinder(height: length, radius: thickness), materials: [UnlitMaterial(color: .blue)])
        axisZ.position = [0, 0, length / 2]
        axisZ.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
        
        axes.addChild(origin)
        axes.addChild(axisX)
        axes.addChild(axisY)
        axes.addChild(axisZ)
        return axes
    }
}

extension simd_quatf {
    func reversed(around axis: SIMD3<Float> = .upward) -> simd_quatf {
        return self * simd_quatf(angle: -.pi, axis: axis)
    }
}
