import simd

extension SIMD3<Float> {

    static func distance(_ first: SIMD3<Float>, _ second: SIMD3<Float>) -> Float {
        (first - second).length()
    }

    static func dot(_ first: SIMD3<Float>, _ second: SIMD3<Float>) -> Float {
        first.x * second.x + first.y * second.y + first.z * second.z
    }

    static var upward: SIMD3<Float> {
        SIMD3<Float>(0, 1, 0)
    }

    static var down: SIMD3<Float> {
        SIMD3<Float>(0, -1, 0)
    }

    static var left: SIMD3<Float> {
        SIMD3<Float>(1, 0, 0)
    }

    static var right: SIMD3<Float> {
        SIMD3<Float>(-1, 0, 0)
    }

    static var forward: SIMD3<Float> {
        SIMD3<Float>(0, 0, 1)
    }

    static var back: SIMD3<Float> {
        SIMD3<Float>(0, 0, -1)
    }
    
    static func normalizeIfNonZero(_ vector: SIMD3<Float>) -> SIMD3<Float> {
        return simd_length(vector) > 0 ? normalize(vector) : vector
    }

    init(_ float4: SIMD4<Float>) {
        self.init()

        x = float4.x
        y = float4.y
        z = float4.z
    }

    func length() -> Float {
        sqrt(x * x + y * y + z * z)
    }

    func normalized() -> SIMD3<Float> {
        self * 1 / length()
    }

    func setX(_ value: Float) -> SIMD3<Float> {
        SIMD3<Float>(value, y, z)
    }

    func setY(_ value: Float) -> SIMD3<Float> {
        SIMD3<Float>(x, value, z)
    }

    func setZ(_ value: Float) -> SIMD3<Float> {
        SIMD3<Float>(x, y, value)
    }
}

extension SIMD4<Float> {
    var xyz: SIMD3<Float> {
        [x, y, z]
    }
}

