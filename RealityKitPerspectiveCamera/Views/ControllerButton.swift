import SwiftUI

struct ControllerButton: View {
    let imageName: String
    let action: (Bool) -> Void
    
    var body: some View {
        Button {} label: {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 64, height: 64)
//                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressedButtonStyle {
            action($0)
        })
    }
}

struct PressedButtonStyle: ButtonStyle {
    var onPressChanged: (Bool) -> Void
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.5 : 1)
            .onChange(of: configuration.isPressed, { _, isPressed in
                onPressChanged(isPressed)
            })
    }
}
