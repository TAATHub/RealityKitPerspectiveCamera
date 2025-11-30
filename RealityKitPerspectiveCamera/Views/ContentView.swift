import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    @State private var count: Int = 0

    var body: some View {
        VStack(spacing: 16) {            
            HStack(spacing: 40) {
                leftController
                    .frame(width: 192)
                
                OffscreenRenderView()
                
                rightController
                    .frame(width: 192)
            }

            ToggleImmersiveSpaceButton()
        }
        .padding(40)
        .onChange(of: appModel.crystalCount) { _, newValue in
            count = newValue
        }
        .ornament(attachmentAnchor: .scene(.top)) {
            Text("Crystal: \(count) / 10")
                .font(.title)
                .padding(24)
                .glassBackgroundEffect(in: .rect(cornerRadius: 48))
        }
    }
    
    private var leftController: some View {
        VStack(spacing: 0) {
            ControllerButton(imageName: "arrowtriangle.up.fill") {
                appModel.controlParameter.forward = $0 ? 1 : 0
            }
            
            HStack(spacing: 0) {
                ControllerButton(imageName: "arrowtriangle.left.fill") {
                    appModel.controlParameter.rotation = $0 ? 1 : 0
                }
                
                Spacer()
                
                ControllerButton(imageName: "arrowtriangle.right.fill") {
                    appModel.controlParameter.rotation = $0 ? -1 : 0
                }
            }
            
            ControllerButton(imageName: "arrowtriangle.down.fill") {
                appModel.controlParameter.forward = $0 ? -1 : 0
            }
        }
    }
    
    private var rightController: some View {
        VStack(spacing: 40) {
            ControllerButton(imageName: "arrowtriangle.up.fill") {
                appModel.controlParameter.up = $0 ? 1 : 0
            }
            
            ControllerButton(imageName: "arrowtriangle.down.fill") {
                appModel.controlParameter.up = $0 ? -1 : 0
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel.shared)
}
