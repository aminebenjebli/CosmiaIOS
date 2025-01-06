import SwiftUI

struct Projectile: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGSize = CGSize(width: 0, height: -10) // Default: moves up
    
    mutating func updatePosition() {
        position.x += velocity.width
        position.y += velocity.height
    }
}
