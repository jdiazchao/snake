//
//  TypingWindow.swift
//  Movement
//
//  Created by Jorge Díaz Chao on 22/03/2020.
//  Copyright © 2020 Jorge Díaz Chao. All rights reserved.
//

import Cocoa

enum buttonPressed {
    case up, down, right, left, reset
}

extension Notification.Name {
    static let moveUp = Notification.Name("moveUp") //126 or 13
    static let moveDown = Notification.Name("moveDown") //125 or 2
    static let moveLeft = Notification.Name("moveLeft") //123 or 1
    static let moveRight = Notification.Name("moveRight") //124 or 0
    static let reset = Notification.Name("reset") //15
}

class TypingWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        //print("Key #\(event.keyCode) pressed.")
        switch event.keyCode {
        case 15:
            NotificationCenter.default.post(name: .reset, object: nil)
        case 126, 13:
            NotificationCenter.default.post(name: .moveUp, object: nil)
        case 125, 1:
            NotificationCenter.default.post(name: .moveDown, object: nil)
        case 123, 0:
            NotificationCenter.default.post(name: .moveLeft, object: nil)
        case 124, 2:
            NotificationCenter.default.post(name: .moveRight, object: event.keyCode)
        default:
            print("Unexpected case.")
        }
    }
}
