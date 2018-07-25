//
//  Stack.swift
//  MusicPlayer
//
//  Created by Andy Yu on 28/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import Foundation
import MediaPlayer

public struct Stack<MPMediaItem> {
    fileprivate var data = [MPMediaItem]()

    mutating func push(_ item: MPMediaItem) {
    data.append(item)
    }
    
    var count: Int {
        return data.count
    }
    
    var isEmpty: Bool {
        return data.isEmpty
    }

    mutating func pop() -> MPMediaItem {
    return data.removeLast()
    }

    func peek() -> MPMediaItem {
    return data.last!
    }
    
    func returnData() -> [MPMediaItem] {
        return data
    }
 }

/*public struct Stack<T> {
    fileprivate var data: Array<T> = []
    
    mutating func push(_ item: T) {
        data.append(item)
    }
    
    mutating func pop() -> T {
        return data.removeLast()
    }
    
    mutating func count() -> Int {
        return data.count
    }
    
    func peek() -> T {
        return data.last!
    }
} */
