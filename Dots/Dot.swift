//
//  Dot.swift
//  Dots
//
//  Created by Richard Hartmann on 2/2/15.
//  Copyright (c) 2015 Richard Hartmann. All rights reserved.
//

import SpriteKit

enum DotColor: Int, Printable {
    case Unknown = 0, Blue, Yellow, Green, Red, Purple
    
    var spriteName: SKColor {
        let spriteNames = [
            SKColor.blueColor(),
            SKColor.yellowColor(),
            SKColor.greenColor(),
            SKColor.redColor(),
            SKColor.purpleColor()]
        
        return spriteNames[rawValue - 1]
    }
    
    static func random() -> DotColor {
        return DotColor(rawValue: Int(arc4random_uniform(5))+1)!
    }
    
    var description: String {
        return spriteName.description
    }
}

class Dot : Printable, Hashable {
    var column: Int
    var row: Int
    let dotColor: DotColor
    var sprite: SKShapeNode?
    
    init(column: Int, row: Int, dotColor: DotColor) {
        self.column = column
        self.row = row
        self.dotColor = dotColor
    }
    
    var description: String {
        return "type:\(dotColor) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row*10+column
    }
}

func ==(lhs: Dot, rhs: Dot) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
