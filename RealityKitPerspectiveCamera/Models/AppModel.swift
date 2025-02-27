import SwiftUI
import RealityFoundation

@MainActor
@Observable
class AppModel {
    static let shared = AppModel()
    
    var scene: Entity?
    var cameraTransform: Transform?
    var controlParameter: ControlParameter = .init()
    
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
