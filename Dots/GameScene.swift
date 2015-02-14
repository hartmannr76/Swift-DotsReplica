//
//  GameScene.swift
//  Dots
//
//  Created by Richard Hartmann on 2/2/15.
//  Copyright (c) 2015 Richard Hartmann. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    var level: Level!
    
    var TileWidth: CGFloat = 42.0
    var TileHeight: CGFloat = 42.0
    
    let gameLayer = SKNode()
    let dotsLayer = SKNode()
    let drawLineLayer = SKNode()
    
    var toDrawFromDot = CGPoint()
    //var drawLineShape: CGShape?
    var dotStack = Stack<Dot>()
    var prevDot: Dot?
    var drawLine = SKShapeNode()
    var pathToDraw: CGMutablePathRef?
    var canDrawLine = true
    
    var prevX: Int?
    var prevY: Int?
    
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let layerPosition = CGPoint(x: -TileWidth * CGFloat(NumColumns)/2, y: -TileHeight * CGFloat(NumRows)/2)
        
        dotsLayer.position = layerPosition
        addChild(gameLayer)
        gameLayer.addChild(drawLineLayer)
        gameLayer.addChild(dotsLayer)
        
    }
    
    func addSpritesForDots(dots: Set<Dot>) {
        for dot in dots {
            //let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            let sprite = SKShapeNode(circleOfRadius: 10)
            sprite.position = pointForColumn(dot.column, row: dot.row)
            sprite.fillColor = dot.dotColor.spriteName
            sprite.strokeColor = dot.dotColor.spriteName
            dotsLayer.addChild(sprite)
            
            dot.sprite = sprite
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func convertPoint(point: CGPoint) -> (sucess: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < (CGFloat(NumColumns)*TileWidth) && point.y >= 0 && point.y < (CGFloat(NumRows)*TileHeight) {
            // check to se if it is in the circle
            var xInt = Int(point.x/TileWidth)
            var yInt = Int(point.y/TileHeight)
            return (true, xInt, yInt)
        }
        else {
            return (false, 0, 0)
        }
    }
    
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(dotsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let dot = level.dotAtColumn(column, row: row) {
                toDrawFromDot = pointForColumn(column, row: row)
                pathToDraw = CGPathCreateMutable()
                var x = toDrawFromDot.x + dotsLayer.position.x
                var y = toDrawFromDot.y + dotsLayer.position.y
                //println("\(x), \(y)")
                CGPathMoveToPoint(pathToDraw, nil, x, y)
                
                //var shape = CAShapeLayer()
                //shape.path = pathToDraw;
                //shape.fillColor = dot.dotColor.spriteName.CGColor
                //drawLineLayer.add
                
                prevDot = dot
                
                drawLine = SKShapeNode()
                drawLine.path = pathToDraw
                drawLine.lineWidth = 8
                drawLine.strokeColor = dot.dotColor.spriteName
                drawLineLayer.addChild(drawLine)
                
                prevX = column
                prevY = row
                
                animateDotTouchAction(dot)
            }
        }
        
    }
    
    func animateDotTouchAction(dot: Dot) {
        // clear dots children
        dot.sprite?.removeAllChildren()
        
        var copyOfDot = dot.sprite?.copy() as SKShapeNode
        copyOfDot.position = CGPoint(x: 0, y: 0)
        let dotTouchDuration = 0.75
        var fadeAction = SKAction.fadeAlphaTo(0, duration: dotTouchDuration)
        var scaleAction = SKAction.scaleBy(2, duration: dotTouchDuration)
        var touchAction = SKAction.group([fadeAction, scaleAction])
        dot.sprite?.addChild(copyOfDot)
        copyOfDot.runAction(touchAction) {
            copyOfDot.removeFromParent()
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let currPosition = touch.locationInNode(self)
        //println("\(currPosition.x), \(currPosition.y)")
        // check if we moved into an acceptable dot
        let location = touch.locationInNode(dotsLayer)
        
        pathToDraw = CGPathCreateMutable()
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let dot = level.dotAtColumn(column, row: row) {
                var xInt = Int(location.x/TileWidth)
                var yInt = Int(location.y/TileHeight)
                
                var inDot = dot.sprite?.containsPoint(location)
                if (((prevX == column && prevY == row + 1) ||
                    (prevX == column && prevY == row - 1) ||
                    (prevX == column + 1 && prevY == row) ||
                    (prevX == column - 1 && prevY == row)) &&
                    dot.dotColor == prevDot?.dotColor && inDot != nil)
                {
                    
                    println("\(column), \(row)")
                    // can we make a square
                    if dotStack.count > 0 && dotStack.isInStack(dot) && canDrawLine && dot != dotStack.peek()  {
                        // if the dot is in the stack but is not the last dot, we have made a box
                        for i in 0..<NumColumns {
                            for j in 0..<NumRows {
                                var dotAt = level.dotAtColumn(i, row: j)
                                if dotAt?.dotColor == dot.dotColor {
                                        animateDotTouchAction(dotAt!)
                                }
                            }
                        }
                        //drawLineLayer.children[drawLineLayer.children.count-1].removeFromParent()
                        var x = toDrawFromDot.x + dotsLayer.position.x
                        var y = toDrawFromDot.y + dotsLayer.position.y
                        var newPoint = pointForColumn(column, row: row)
                        var newDrawX = newPoint.x + dotsLayer.position.x
                        var newDrawY = newPoint.y + dotsLayer.position.y
                        CGPathMoveToPoint(pathToDraw, nil, x, y)
                        CGPathAddLineToPoint(pathToDraw, nil, newDrawX, newDrawY)
                        drawLine.path = pathToDraw
                        canDrawLine = false
                        prevX = column
                        prevY = row
                        dotStack.push(prevDot!)
                        
                        prevDot = dot
                    }
                    else if dotStack.count > 0 && dot == dotStack.peek() && inDot != nil{
                        // remove last child
                        var newPoint = pointForColumn(column, row: row)
                        toDrawFromDot = newPoint
                        
                        if canDrawLine {
                            drawLine = drawLineLayer.children[drawLineLayer.children.count-1] as SKShapeNode
                            drawLineLayer.children[drawLineLayer.children.count-2].removeFromParent()
                        }
                        else {
                            drawLineLayer.children[drawLineLayer.children.count-1].removeFromParent()
                            canDrawLine = true
                            
                            // create the new drawline
                            drawLine = SKShapeNode()
                            drawLine.path = pathToDraw
                            drawLine.lineWidth = 8
                            drawLine.strokeColor = dot.dotColor.spriteName
                            drawLineLayer.addChild(drawLine)
                            //prevDot = dotStack.pop()
                        }
                        prevDot = dotStack.pop()
                        var x = toDrawFromDot.x + dotsLayer.position.x
                        var y = toDrawFromDot.y + dotsLayer.position.y
                        //println("\(x), \(y)")
                        CGPathMoveToPoint(pathToDraw, nil, x, y)
                        prevX = column
                        prevY = row
                        println("Stack count: \(dotStack.count)")
                        
                        println("Draw count: \(drawLineLayer.children.count)")
                        println(prevDot)
                        
                        x = toDrawFromDot.x + dotsLayer.position.x
                        y = toDrawFromDot.y + dotsLayer.position.y
                        CGPathMoveToPoint(pathToDraw, nil, x, y)
                        CGPathAddLineToPoint(pathToDraw, nil, currPosition.x, currPosition.y)
                        drawLine.path = pathToDraw
                    }
                    else if canDrawLine && inDot != nil
                    {
                        var x = toDrawFromDot.x + dotsLayer.position.x
                        var y = toDrawFromDot.y + dotsLayer.position.y
                        var newPoint = pointForColumn(column, row: row)
                        var newDrawX = newPoint.x + dotsLayer.position.x
                        var newDrawY = newPoint.y + dotsLayer.position.y
                        CGPathMoveToPoint(pathToDraw, nil, x, y)
                        CGPathAddLineToPoint(pathToDraw, nil, newDrawX, newDrawY)
                        drawLine.path = pathToDraw
                        
                        var newLine = SKShapeNode()
                        newLine.path = pathToDraw
                        newLine.lineWidth = 8
                        newLine.strokeColor = drawLine.strokeColor
                        
                        toDrawFromDot = newPoint
                        
                        x = toDrawFromDot.x + dotsLayer.position.x
                        y = toDrawFromDot.y + dotsLayer.position.y
                        
                        CGPathMoveToPoint(pathToDraw, nil, x, y)
                        prevX = column
                        prevY = row
                        
                        drawLineLayer.addChild(newLine)
                        drawLine = newLine
                        
                        dotStack.push(prevDot!)
                        
                        println("Stack count: \(dotStack.count)")
                        prevDot = dot
                        println("Draw count: \(drawLineLayer.children.count)")
                        
                        animateDotTouchAction(dot)
                        
                        x = toDrawFromDot.x + dotsLayer.position.x
                        y = toDrawFromDot.y + dotsLayer.position.y
                        CGPathMoveToPoint(pathToDraw, nil, x, y)
                        CGPathAddLineToPoint(pathToDraw, nil, currPosition.x, currPosition.y)
                        drawLine.path = pathToDraw
                    }
                    if(dotStack.count > 0) {
                        println("Prev:")
                        println("\(dotStack.peek().column), \(dotStack.peek().row)")
                    }
                }
                else if canDrawLine
                {
                    var x = toDrawFromDot.x + dotsLayer.position.x
                    var y = toDrawFromDot.y + dotsLayer.position.y
                    CGPathMoveToPoint(pathToDraw, nil, x, y)
                    CGPathAddLineToPoint(pathToDraw, nil, currPosition.x, currPosition.y)
                    
                    drawLine.path = pathToDraw
                }
            }
        }
        else
        {
            if canDrawLine {
                var x = toDrawFromDot.x + dotsLayer.position.x
                var y = toDrawFromDot.y + dotsLayer.position.y
                CGPathMoveToPoint(pathToDraw, nil, x, y)
                CGPathAddLineToPoint(pathToDraw, nil, currPosition.x, currPosition.y)
                drawLine.path = pathToDraw
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // we now need to blow away the stack
        // if we let go when we were not allowed to draw, lets add all items back to stack
        if canDrawLine == false {
            for i in 0..<NumColumns {
                for j in 0..<NumRows {
                    var dotAt = level.dotAtColumn(i, row: j)
                    if dotAt?.dotColor == prevDot?.dotColor {
                        if !dotStack.isInStack(dotAt!) {
                            dotStack.push(dotAt!)
                        }
                    }
                }
            }
        }
        
        drawLineLayer.removeAllChildren()
        animateDotsDrop(dotStack)
        prevDot = nil
        dotStack = Stack<Dot>()
        canDrawLine = true
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func animateDotsDrop(dotsToClear: Stack<Dot>) {
        // we need to find the new locations of dots
        if(dotsToClear.count > 0)
        {
            for dot in dotsToClear.elems {
                dot.sprite?.removeFromParent()
                dot.sprite = nil
                //dotsLayer.removeChildrenInArray(dotsToClear.elems)
                //dot.dotColor = DotColor.Unknown
            }
            prevDot!.sprite?.removeFromParent()
            prevDot!.sprite = nil
            
            
            let Duration: NSTimeInterval = 0.15
            var bounceFactor = CGFloat(0.2)
            var bounceMax = CGFloat(self.size.height/20)
            let bounceDuration: NSTimeInterval = 0.05
            //var bounce = SKAction.sequence([
            //    SKAction.moveByX(0, y: bounceMax*bounceFactor, duration: 0.1),
            //    SKAction.moveByX(0, y:-bounceMax*bounceFactor, duration: 0.1),
            //    SKAction.moveByX(0, y: bounceMax*bounceFactor/2, duration: 0.1),
            //    SKAction.moveByX(0, y:-bounceMax*bounceFactor/2, duration: 0.1)])
            var bounceUp = SKAction.moveByX(0, y: bounceMax*bounceFactor, duration: 0.1)
            bounceUp.timingMode = .EaseOut
            var bounceBackDown = SKAction.moveByX(0, y:-bounceMax*bounceFactor, duration: 0.1)
            bounceBackDown.timingMode = .EaseIn
            var bounce = SKAction.sequence([ bounceUp
                   ,bounceBackDown])
                    //SKAction.moveByX(0, y: bounceMax*bounceFactor/2, duration: 0.1),
                   //SKAction.moveByX(0, y:-bounceMax*bounceFactor/2, duration: 0.1)])
            // we need to drop dots
            for i in 0..<NumColumns {
                var howManyRowsToDropForDots = 0
                for j in 0..<NumRows {
                    // if there is no dot, increment the drop counter
                    if level.dotAtColumn(i, row: j)?.sprite == nil {
                        howManyRowsToDropForDots++
                    }
                    else
                    {
                        if(howManyRowsToDropForDots > 0)
                        {
                            // otherwise we set the action for the dot to drop
                            var newPosition = pointForColumn(i, row: j-howManyRowsToDropForDots)
                            var newPositionMove = SKAction.moveTo(newPosition, duration: Duration)
                            
                            var moveDot = SKAction.sequence([newPositionMove,
                                bounce])
                            
                            moveDot.timingMode = .EaseOut
                            level.dotAtColumn(i, row: j)?.sprite?.runAction(moveDot)
                            level.dropDot(i, row: j, dropAmount: howManyRowsToDropForDots)
                        }
                    }
                }
                
                // add dots to column. the existing drop count should tell us how many we need to add
                var rowsDown = howManyRowsToDropForDots
                for newDot in 0..<howManyRowsToDropForDots {
                    var dot = Dot(column: i, row: NumRows-rowsDown, dotColor: DotColor.random())
                    level.addDot(dot.column, row: dot.row, newDot: dot)
                    
                    var newPosition = pointForColumn(i, row: dot.row)
                    
                    var moveDot = SKAction.sequence([SKAction.moveTo(newPosition, duration: Duration),
                        bounce])
                    
                    moveDot.timingMode = .EaseOut
                    
                    let sprite = SKShapeNode(circleOfRadius: 10)
                    sprite.position = pointForColumn(dot.column, row: dot.row)
                    sprite.position.y = self.size.height
                    sprite.fillColor = dot.dotColor.spriteName
                    sprite.strokeColor = dot.dotColor.spriteName
                    dotsLayer.addChild(sprite)
                    
                    dot.sprite = sprite
                    sprite.runAction(moveDot)
                    rowsDown--
                }
            }
        }
        
        
    }
}
