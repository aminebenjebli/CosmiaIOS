import SwiftUI

struct Asteroid: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    
    init(size: CGFloat = 40) {
        self.size = size
        position = CGPoint(
            x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
            y: CGFloat.random(in: -500...0)
        )
    }
    
    mutating func reset() {
        position = CGPoint(
            x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
            y: CGFloat.random(in: -500...0)
        )
    }
}
