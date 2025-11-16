import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    @State private var count: Int = 0

    var body: some View {
        VStack(spacing: 40) {
            Text("Crystal: \(count) / 10")
            
            HStack(spacing: 40) {
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
                .frame(width: 192)
                
                OffscreenRenderView()
                    .aspectRatio(16/9, contentMode: .fit)
                
                VStack(spacing: 40) {
                    ControllerButton(imageName: "arrowtriangle.up.fill") {
                        appModel.controlParameter.up = $0 ? 1 : 0
                    }
                    
                    ControllerButton(imageName: "arrowtriangle.down.fill") {
                        appModel.controlParameter.up = $0 ? -1 : 0
                    }
                }
                .frame(width: 192)
            }
            
            ToggleImmersiveSpaceButton()
        }
        .padding(40)
        .frame(width: 1200, height: 600)
        .onChange(of: appModel.crystalCount) { _, newValue in
            count = newValue
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel.shared)
}
