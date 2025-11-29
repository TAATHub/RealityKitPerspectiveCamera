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
            // Change to SampleImmersiveView() to check immersive view with sample scenes.
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
