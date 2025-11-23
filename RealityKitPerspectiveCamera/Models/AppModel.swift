import SwiftUI
import RealityKit

@MainActor
@Observable
class AppModel {
    static let shared = AppModel()
    
    var crystalCount: Int = 0

    var renderTextureScene: RenderTextureScene?
    var droneCameraTransform: Transform = .init()
    var skyCameraTransform: Transform = .init()

    var controlParameter: ControlParameter = .init()
    
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
