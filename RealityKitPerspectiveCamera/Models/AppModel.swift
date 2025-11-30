import SwiftUI
import RealityKit

@MainActor
@Observable
class AppModel {
    static let shared = AppModel()
    
    var crystalCount: Int = 0

    var renderTextureScene: RenderTextureScene?
    var renderCameras: [RenderCameraType: Transform] = [.droneCamera: .init(), .camera1: .init(), .camera2: .init()]

    var controlParameter: ControlParameter = .init()
    
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}

enum RenderCameraType: Int {
    case droneCamera
    case camera1
    case camera2
    
    var entityName: String {
        switch self {
        case .droneCamera:
            return "Drone"
        case .camera1:
            return "Camera_1"
        case .camera2:
            return "Camera_2"
        }
    }
    
    @MainActor
    var descriptor: RenderTextureScene.CameraAndTexture.Descriptor {
        switch self {
        case .droneCamera:
            return .init(width: 1600, height: 900)
        case .camera1, .camera2:
            return .init(width: 800, height: 640)
        }
    }
    
    var planeSize: (width: Float, height: Float) {
        switch self {
        case .droneCamera:
            return (1.6, 0.9)
        case .camera1, .camera2:
            return (0.8, 0.64)
        }
    }
}
