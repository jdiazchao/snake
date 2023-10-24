//
//  ContentView.swift
//  Snake
//
//  Created by Jorge Díaz Chao on 23/04/2020.
//  Copyright © 2020 Jorge Díaz Chao. All rights reserved.
//

import SwiftUI

class GlobalEnvironment: ObservableObject {
    @Published var player: Snake = Snake(xPos: 9, yPos: 9)
    @Published var food: Food = Food(position: Position(x: Int.random(in: 1...17), y: Int.random(in: 1...17)))
    @Published var slots: Int = 17
    @Published var bestScore: Int = 0
    @Published var running: Bool = false;
}

public struct Snake {
    @EnvironmentObject var environment: GlobalEnvironment
    
    var position: Position
    var score: Int
    var direction: direction
    var tail: [Position]
    
    enum direction {
        case up, down, right, left
    }
    
    init(xPos: Int, yPos: Int) {
        self.position = Position(x: xPos, y: yPos)
        self.score = 0
        self.direction = .right
        self.tail = [self.position, self.position, self.position]
    }
    
    mutating func respawn() {
        self.position = Position(x: 9, y: 9)
        self.score = 0
        self.direction = .right
        self.tail.removeAll()
        self.tail = [self.position, self.position, self.position]
    }
}
public struct Food {
    var position: Position
    
    mutating func respawn(){
        self.position = Position(x: Int.random(in: 1...17), y: Int.random(in: 1...17))
    }
}
public struct Position {
    var x: Int
    var y: Int
}

struct ContentView: View {
    
    @EnvironmentObject var environment: GlobalEnvironment
    
    var body: some View {
        ZStack {
            ZStack {
                VStack(spacing: 10) {
                    TopBarView()
                    GameView()
                }
            }
        .frame(width: 550, height: 640)
        }
        .background(Color(red: 235 / 255, green: 235 / 255, blue: 235 / 255))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TopBarView: View {
    
    @EnvironmentObject var environment: GlobalEnvironment
    
    let gradientStart = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    let gradientEnd = Color(red: 235 / 255, green: 235 / 255, blue: 235 / 255)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7.5)
                .fill(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientStart, gradientEnd]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(Color(.gray))
            HStack(spacing: 20) {
                Text("Score: \(environment.player.score)")
                    .font(.title)
                    .foregroundColor(Color(.darkGray))
                Text("Best: \(environment.bestScore)")
                    .font(.title)
                    .foregroundColor(Color(.darkGray))
                Spacer()
                /*Stepper(value: $environment.slots, in: 17...17, step: 2) {
                    Text("\(environment.slots)")
                        .font(.title)
                        .foregroundColor(Color(.gray))
                }*/
            }
            .padding(.horizontal, 25)
        }
        .frame(width: 500, height: 50)
    }
}

struct GameView: View {
    
    @EnvironmentObject var environment: GlobalEnvironment
    let cycle = Timer.publish(every: 0.125, on: .main, in: .common).autoconnect()
    
    let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
    let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .leading, endPoint: .trailing))
            VStack(spacing: 2.5) {
                ForEach((1...environment.slots).reversed(), id: \.self) { yRow in
                    HStack(spacing: 2.5) {
                        ForEach((1...self.environment.slots), id: \.self) { xRow in
                            RoundedRectangle(cornerRadius: 2.5)
                                .foregroundColor(self.colored(x: xRow, y: yRow))
                                .opacity(self.shaded(x: xRow, y: yRow))
                        }
                    }
                }
            }
            .padding(10)
            .onReceive(cycle) { _ in
                self.update()
            }
            if environment.running == false {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .leading, endPoint: .trailing))
                VStack {
                    VStack(spacing: -15) {
                        Text("Snake")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Made by Jorge Díaz Chao")
                            .font(.system(size: 25))
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                    }
                    Button(action: {self.play()}) {
                        Text("Play")
                            .font(.subheadline)
                    }
                }
            }
        }
        .frame(width: 500, height: 500)
        .onReceive(NotificationCenter.default.publisher(for: .moveUp)) { _ in
            if (self.environment.player.direction != .down) {
                self.environment.player.direction = .up
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .moveDown)) { _ in
            if (self.environment.player.direction != .up) {
                self.environment.player.direction = .down
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .moveLeft)) { _ in
            if (self.environment.player.direction != .right) {
                self.environment.player.direction = .left
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .moveRight)) { _ in
            if (self.environment.player.direction != .left) {
                self.environment.player.direction = .right
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .reset)) { _ in
            self.reset()
        }
    }
    
    func play(){
        environment.running = true
    }
    
    func colored(x: Int, y: Int) -> Color {
        var color = Color(.white)
        if x == environment.player.position.x && y == environment.player.position.y {
            color = Color(.white)
        } else if x == environment.food.position.x && y == environment.food.position.y {
            color = Color(.darkGray)
        } else {
            for part in environment.player.tail {
                if x == part.x && y == part.y {
                    color = Color(.white)
                }
            }
        }
        return color
    }
    
    func shaded(x: Int, y: Int) -> Double {
        var opacity = 0.15
        if x == environment.player.position.x && y == environment.player.position.y {
            opacity = 1
        } else if x == environment.food.position.x && y == environment.food.position.y {
            opacity = 0.9
        } else {
            for part in environment.player.tail {
                if x == part.x && y == part.y {
                    opacity = 0.6
                }
            }
        }
        return opacity
    }
    
    func checkCollision() {
        if environment.player.position.x == environment.food.position.x && environment.player.position.y == environment.food.position.y {
            environment.food.respawn()
            environment.player.score += 1
            environment.player.tail.insert(environment.player.position, at: environment.player.score + 2)
        } else {
            for part in environment.player.tail {
                if environment.player.position.x == part.x && environment.player.position.y == part.y {
                    self.reset()
                }
            }
        }
    }
    
    func moveUp() {
        if environment.player.position.y >= environment.slots {
            environment.player.position.y = 1
        } else {
            environment.player.position.y += 1
        }
    }
    func moveDown() {
        if environment.player.position.y <= 1 {
            environment.player.position.y = environment.slots
        } else {
            environment.player.position.y -= 1
        }
    }
    func moveLeft() {
        if environment.player.position.x <= 1 {
            environment.player.position.x = environment.slots
        } else {
            environment.player.position.x -= 1
        }
    }
    func moveRight() {
        if environment.player.position.x >= environment.slots {
            environment.player.position.x = 1
        } else {
            environment.player.position.x += 1
        }
    }
    func reset() {
        environment.running = false
        environment.player.respawn()
        environment.food.respawn()
    }
    
    func move() {
        switch environment.player.direction {
        case .up:
            moveUp()
        case .down:
            moveDown()
        case .right:
            moveRight()
        case .left:
            moveLeft()
        }
    }
    
    func update() {
        if environment.running == true {
            if environment.player.score > environment.bestScore {
                environment.bestScore = environment.player.score
            }
            environment.player.tail.insert(environment.player.position, at: 0)
            environment.player.tail.remove(at: environment.player.score + 3)
            move()
            checkCollision()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
