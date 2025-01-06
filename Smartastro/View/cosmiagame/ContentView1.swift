import SwiftUI

struct ContentView1: View {
    @State private var spaceshipPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
    @State private var stars: [Star] = []
    @State private var asteroids: [Asteroid] = []
    @State private var playerProjectiles: [Projectile] = []
    @State private var bossProjectiles: [Projectile] = []
    @State private var score: Int = 0
    @State private var playerHealth: Int = 3
    @State private var bossHealth: Int = 0
    @State private var bossAppeared: Bool = false
    @State private var gameOver: Bool = false
    @State private var bossLevel: Int = 0
    @State private var isPaused: Bool = false
    @State private var speedMultiplier: CGFloat = 1.0
    @State private var bossPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
    
    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    private let firingTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    private let bossMovementTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    private let bossBoostAttackTimer = Timer.publish(every: 20.0, on: .main, in: .common).autoconnect()
    
    var onGameOver: (Int) -> Void

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ForEach(stars) { star in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .frame(width: 30, height: 30)
                    .position(star.position)
            }
            
            ForEach(asteroids) { asteroid in
                Image(systemName: "circle.fill")
                    .foregroundColor(.gray)
                    .frame(width: asteroid.size, height: asteroid.size)
                    .position(asteroid.position)
            }
            
            ForEach(playerProjectiles) { projectile in
                Rectangle()
                    .frame(width: 5, height: 20)
                    .foregroundColor(.green)
                    .position(projectile.position)
            }
            
            ForEach(bossProjectiles) { projectile in
                Rectangle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.red)
                    .position(projectile.position)
            }
            
            Image("Spaceship")
                .resizable()
                .frame(width: 50, height: 50)
                .position(spaceshipPosition)
            
            if bossAppeared {
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.purple)
                    .position(bossPosition)
                    .animation(.easeInOut(duration: 1.5), value: bossPosition)
            }
            
            VStack {
                HStack {
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading)
                    Spacer()
                    Text("Health: \(playerHealth)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.trailing)
                }
                
                if bossAppeared {
                    ProgressView(value: Double(bossHealth), total: Double(bossLevel * 10))
                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                        .padding()
                        .frame(width: 200)
                }
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: togglePause) {
                        Text(isPaused ? "Resume" : "Pause")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            
            if gameOver {
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    if bossHealth <= 0 {
                        Text("You Defeated the Boss!")
                            .font(.title)
                            .foregroundColor(.green)
                    } else {
                        Text("You Lost!")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Button("Restart") {
                        restartGame()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Exit Game") {
                        onGameOver(score)
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    spaceshipPosition = value.location
                }
        )
        .onReceive(timer) { _ in
            if !isPaused { updateGame() }
        }
        .onReceive(firingTimer) { _ in
            if !isPaused { shootProjectile() }
        }
        .onReceive(bossMovementTimer) { _ in
            if !isPaused && bossAppeared { moveBossSmoothly() }
        }
        .onReceive(bossBoostAttackTimer) { _ in
            if !isPaused && bossAppeared { bossBoostAttack() }
        }
        .onAppear {
            spawnStars()
            spawnAsteroids()
        }
    }

    func togglePause() {
        isPaused.toggle()
    }
    
    func restartGame() {
        spaceshipPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100)
        stars = []
        asteroids = []
        playerProjectiles = []
        bossProjectiles = []
        score = 0
        playerHealth = 3
        bossHealth = 0
        bossAppeared = false
        bossLevel = 0
        speedMultiplier = 1.0
        bossPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
        gameOver = false
        spawnStars()
        spawnAsteroids()
    }
    
    func updateGame() {
        if gameOver { return }
        
        for i in stars.indices {
            stars[i].position.y += 5 * speedMultiplier
            if stars[i].position.y > UIScreen.main.bounds.height {
                stars[i].reset()
            } else if isColliding(position1: stars[i].position, position2: spaceshipPosition) {
                score += 1
                stars[i].reset()
            }
        }
        
        for i in asteroids.indices {
            asteroids[i].position.y += 7 * speedMultiplier
            if asteroids[i].position.y > UIScreen.main.bounds.height {
                asteroids[i].reset()
            }
        }
        
        for i in playerProjectiles.indices.reversed() {
            playerProjectiles[i].position.y -= 10
            if playerProjectiles[i].position.y < 0 {
                playerProjectiles.remove(at: i)
            } else if bossAppeared && isCollidingWithBoss(playerProjectiles[i].position) {
                bossHealth -= 1
                playerProjectiles.remove(at: i)
                if bossHealth <= 0 {
                    bossAppeared = false
                    bossLevel += 1
                    speedMultiplier += 0.2
                }
            }
        }
        
        for i in bossProjectiles.indices.reversed() {
            bossProjectiles[i].position.y += 7
            if bossProjectiles[i].position.y > UIScreen.main.bounds.height {
                bossProjectiles.remove(at: i)
            } else if isColliding(position1: bossProjectiles[i].position, position2: spaceshipPosition) {
                playerHealth -= 1
                bossProjectiles.remove(at: i)
                if playerHealth <= 0 {
                    gameOver = true
                    onGameOver(score)
                }
            }
        }
        
        if score >= bossLevel * 30 && !bossAppeared {
            spawnBoss()
        }
        
        if bossAppeared && Int.random(in: 0...100) < 5 {
            bossProjectiles.append(Projectile(position: bossPosition))
        }
    }
    
    func isColliding(position1: CGPoint, position2: CGPoint) -> Bool {
        let xDiff = abs(position1.x - position2.x)
        let yDiff = abs(position1.y - position2.y)
        return xDiff < 40 && yDiff < 40
    }
    
    func isCollidingWithBoss(_ position: CGPoint) -> Bool {
        let xDiff = abs(position.x - bossPosition.x)
        let yDiff = abs(position.y - bossPosition.y)
        return xDiff < 50 && yDiff < 50
    }
    
    func spawnStars() {
        for _ in 0..<5 {
            stars.append(Star())
        }
    }
    
    func spawnAsteroids() {
        for _ in 0..<3 {
            asteroids.append(Asteroid())
        }
    }
    
    func spawnBoss() {
        bossAppeared = true
        bossHealth = bossLevel * 10
    }
    
    func moveBossSmoothly() {
        let newX = CGFloat.random(in: 50...UIScreen.main.bounds.width - 50)
        let newY = CGFloat.random(in: 100...300)
        withAnimation(.easeInOut(duration: 1.5)) {
            bossPosition = CGPoint(x: newX, y: newY)
        }
    }
    
    func bossBoostAttack() {
        for angle in stride(from: 0.0, to: 360.0, by: 15.0) {
            let radians = angle * .pi / 180
            let dx = cos(radians) * 10
            let dy = sin(radians) * 10
            bossProjectiles.append(Projectile(position: bossPosition, velocity: CGSize(width: dx, height: dy)))
        }
    }
    
    func shootProjectile() {
        playerProjectiles.append(Projectile(position: spaceshipPosition))
    }
}
