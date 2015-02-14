//
//  Level.swift
//  Dots
//
//  Created by Richard Hartmann on 2/2/15.
//  Copyright (c) 2015 Richard Hartmann. All rights reserved.
//

import Foundation

let NumColumns = 7
let NumRows = 7

class Level {
    private var dots = Array2D<Dot>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    /*init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"] {
                for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
                    let tileRow = NumRows - row - 1
                    
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }*/
    
    init() {
        
    }
    
    func dotAtColumn(column: Int, row: Int) -> Dot? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return self.dots[column, row]
    }
    
    /*func tileAtColumn(column:Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return self.tiles[column, row]
    }*/
    
    func shuffle() -> Set<Dot> {
        return createInitialDots()
    }
    
    private func createInitialDots() -> Set<Dot> {
        
        var set = Set<Dot>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                //if tiles[column, row] != nil {
                    var dotColor = DotColor.random()
                    let dot = Dot(column: column, row: row, dotColor: dotColor)
                    dots[column, row] = dot
                    
                    set.addElement(dot)
                //}
            }
        }
        
        return set
    }

    func dropDot(column: Int, row: Int, dropAmount: Int)
    {
        var dot = self.dots[column, row]
        dot!.row = row-dropAmount
        self.dots[column, row-dropAmount] = self.dots[column, row]
        self.dots[column, row] = nil
    }
    
    func addDot(column: Int, row: Int, newDot: Dot)
    {
        self.dots[column, row] = newDot
    }
    
    /*func performSwap(swap: Swap)
    {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }*/
}