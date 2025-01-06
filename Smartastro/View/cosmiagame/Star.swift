import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    var position: CGPoint
    
    init() {
        position = CGPoint(
            x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
            y: CGFloat.random(in: -300...0)
        )
    }
    
    mutating func reset() {
        position = CGPoint(
            x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
            y: CGFloat.random(in: -300...0)
        )
    }
}
