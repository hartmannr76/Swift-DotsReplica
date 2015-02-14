struct Stack<T : Hashable> {
    
    var elems = [T]()
    
    mutating func push(elem: T) {
        elems.append(elem)
    }
    
    mutating func pop() -> T {
        return elems.removeLast()
    }
    
    func peek() -> T {
        return elems[elems.endIndex-1]
    }
    
    var count: Int {
        return elems.count
    }
    
    func isInStack(elem: T) -> Bool {
        for i in self.elems {
            if i == elem {
                return true
            }
        }
        
        return false
    }
    
}