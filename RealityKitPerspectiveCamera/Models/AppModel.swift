import SwiftUI
import RealityKit

@MainActor
@Observable
class AppModel {
    static let shared = AppModel()
    
    var crystalCount: Int = 0

    var renderTextureScene: RenderTextureScene?
    var droneCameraTransform: Transform?
    var skyCameraTransform: Transform = .init(rotation: simd_quatf(angle: -.pi / 2, axis: .init(x: 1, y: 0, z: 0)), translation: .init(x: 0, y: 3.0, z: 0))

    var controlParameter: ControlParameter = .init()
    
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
