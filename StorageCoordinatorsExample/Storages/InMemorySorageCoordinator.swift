//
//  InMemorySorageCoordinator.swift
//  minube
//
//  Created by Carlos Roig Salvador on 30/11/16.
//  Copyright © 2016 minube.com. All rights reserved.
//

import Foundation

class InMemoryStorageCoordinator: StorageCoordinator {
    
    var concurrentQueue: DispatchQueue {
        return DispatchQueue(label: "com.userDefaultsStorage", attributes: .concurrent)
    }
    
    var mainQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
    typealias Element = Serializable
    var elements: [Element]?
    
    func getItems<T : Serializable>(completion: @escaping ([T]?) -> Void) {
        self.mainQueue.async {
            completion(self.elements as! [T]?)
        }
    }
    
    func save<T : Serializable>(_ items: [T], completion: @escaping (Bool) -> Void) {
        elements = items
        self.mainQueue.async {
            completion(true)
        }
    }
    
}
