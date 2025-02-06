import Observation

@Observable
class ControlParameter {
    var forward: Double = 0
    var up: Double = 0
    var rotation: Double = 0
}
