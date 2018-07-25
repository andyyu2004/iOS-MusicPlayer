//
//  List.swift
//  MusicPlayer
//
//  Created by Andy Yu on 30/06/18.
//  Copyright © 2018 Andy Yu. All rights reserved.
//

import Foundation
import MediaPlayer

public class Node {
    
    var data: MPMediaItem
    var next: Node?
    weak var previous: Node?
    
    init(_ value: MPMediaItem) {
        self.data = value
    }
}

public class List {
    fileprivate var head: Node?
    private var tail: Node?
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node? {
        return head
    }
    
    public var last: Node? {
        return tail
    }
    
    public func prepend(_ value: MPMediaItem) {
        let newNode = Node(value)
        
        if let headNode = head {
            newNode.next = headNode
            headNode.previous = newNode
        } else {
            tail = newNode
        }
        head = newNode
    }
    
    public func append(_ value: MPMediaItem) {
        let newNode = Node(value)
        
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }
    
    public func nodeAt(index: Int) -> Node? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 {
                    return node
                }
                i -= 1
                node = node!.next
            }
        }
        return nil
    }
    
    public func removeHead() {
        if let headNode = head {
            head = headNode.next
            headNode.next?.previous = nil
        }
    }
    
    public func removeAll() {
        head = nil
        tail = nil
    }
}

extension List: CustomStringConvertible {
    public var description: String {
        var text = "["
        var node = head
        while node != nil {
            text += "\(node!.data.title!)"
            node = node!.next
            if node != nil {
                text += ", "
            }
        }
        return text + "]"
    }
}


