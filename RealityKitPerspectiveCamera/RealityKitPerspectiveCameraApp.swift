import SwiftUI

@main
struct RealityKitPerspectiveCameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AppModel.shared)
        }
        .windowResizability(.contentSize)

        ImmersiveSpace(id: AppModel.shared.immersiveSpaceID) {
            ImmersiveView()
                .environment(AppModel.shared)
                .onAppear {
                    AppModel.shared.immersiveSpaceState = .open
                }
                .onDisappear {
                    AppModel.shared.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
